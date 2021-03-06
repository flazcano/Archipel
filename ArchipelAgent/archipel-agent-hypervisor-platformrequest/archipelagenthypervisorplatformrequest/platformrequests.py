# 
# snapshoting.py
# 
# Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import xmpp
import os
import archipel
from libvirt import *
from pkg_resources import iter_entry_points

from archipelcore.utils import *
from archipelcore.pubsub import *
from archipelcore.archipelPlugin import TNArchipelPlugin
from scorecomputing import TNBasicPlatformScoreComputing

ARCHIPEL_NS_PLATFORM = "archipel:platform"


class TNPlatformRequests (TNArchipelPlugin):
    
    def __init__(self, configuration, entity, entry_point_group):
        """
        initialize the module
        @type entity TNArchipelEntity
        @param entity the module entity
        """
        TNArchipelPlugin.__init__(self, configuration=configuration, entity=entity, entry_point_group=entry_point_group)
        
        self.pubsub_request_in_node     = None
        self.pubsub_request_out_node    = None
        self.computing_unit             = None
        
        # get eventual computing unit plugin
        self.load_computing_unit()
        
        # creates permissions
        self.entity.permission_center.create_permission("platform_allocvm", "Authorizes user to send cross platform request", True)
        
        # register to the node vmrequest
        self.entity.register_hook("HOOK_ARCHIPELENTITY_XMPP_AUTHENTICATED", method=self.manage_platform_vm_request)
    
    
    
    ### Plugin interface
    
    def register_for_stanza(self):
        """
        this method will be called by the plugin user when it will be
        necessary to register module for listening to stanza
        """
        self.entity.xmppclient.RegisterHandler('iq', self.process_iq, ns=ARCHIPEL_NS_PLATFORM)
    
    
    @staticmethod
    def plugin_info():
        """
        return inforations about the plugin
        """
        plugin_friendly_name           = "Hypervisor Platform Request"
        plugin_identifier              = "platformrequest"
        plugin_configuration_section   = None
        plugin_configuration_tokens    = []
        
        return {    "common-name"               : plugin_friendly_name, 
                    "identifier"                : plugin_identifier,
                    "configuration-section"     : plugin_configuration_section,
                    "configuration-tokens"      : plugin_configuration_tokens }
    
    
    
    ### Plugin loading
    
    def load_computing_unit(self):
        """
        loads the external computing unit
        """
        for factory_method in iter_entry_points(group="archipel.plugin.platform.computingunit", name="factory"):
            method              = factory_method.load()
            plugin_content      = method()
            self.computing_unit = plugin_content["plugin"]
            self.entity.log.info("PLATFORMREQ: loading computing unit %s" % plugin_content["info"]["common-name"])
            break
        if not self.computing_unit: 
            self.computing_unit = TNBasicPlatformScoreComputing()
            self.entity.log.info("PLATFORMREQ: using default computing unit")
        
    
    
    
    ### Performs platform actions
    
    def perform_score_computing(self, request):
        """
        compute the score for the given request
        @type request: string
        @param request: the requested action name
        @rtype: float
        @return: the score computed by the computing unit ([0.0, 1.0])
        """
        return self.computing_unit.score(request)
    
    
    
    ### Pubsub management
    
    def manage_platform_vm_request(self, origin, user_info, arguments):
        """
        register to pubsub event node /archipel/platform/requests/in
        and /archipel/platform/requests/out
        """
        nodeVMRequestsInName = "/archipel/platform/requests/in"
        self.entity.log.info("PLATFORMREQ: getting the pubsub node %s" % nodeVMRequestsInName)
        self.pubsub_request_in_node = TNPubSubNode(self.entity.xmppclient, self.entity.pubsubserver, nodeVMRequestsInName)
        self.pubsub_request_in_node.recover()
        self.entity.log.info("PLATFORMREQ: node %s recovered" % nodeVMRequestsInName)
        self.pubsub_request_in_node.subscribe(self.entity.jid.getStripped(), self._handle_request_event)
        self.entity.log.info("PLATFORMREQ: entity %s is now subscribed to events from node %s" % (self.entity.jid, nodeVMRequestsInName))
        
        nodeVMRequestsOutName = "/archipel/platform/requests/out"
        self.entity.log.info("PLATFORMREQ: getting the pubsub node %s" % nodeVMRequestsOutName)
        self.pubsub_request_out_node = TNPubSubNode(self.entity.xmppclient, self.entity.pubsubserver, nodeVMRequestsOutName)
        self.pubsub_request_out_node.recover()
        self.entity.log.info("PLATFORMREQ: node %s recovered" % nodeVMRequestsOutName)
        
    
    
    def _handle_request_event(self, event):
        """
        triggered when a platform wide virtual machine request is received
        """
        items = event.getTag("event").getTag("items").getTags("item")
        
        for item in items:
            item_publisher = xmpp.JID(item.getAttr("publisher"))
            if not item_publisher.getStripped() == self.entity.jid.getStripped():
                try:
                    self.entity.log.info("PLATFORMREQ: received a platform-wide virtual machine request from %s" % item_publisher)
                    request_uuid    = item.getTag("archipel").getAttr("uuid")
                    request_action  = item.getTag("archipel").getAttr("action");
                    
                    if not self.entity.permission_center.check_permission(item_publisher.getStripped(), "platform_%s" % request_action):
                        self.entity.log.warning("user %s have no permission to perform platform action %s" % (item_publisher, request_action))
                        return
                    
                    score = self.perform_score_computing(item)
                    if score:
                        answer_node = xmpp.Node("archipel", attrs={"uuid": request_uuid, "score": score})
                        self.pubsub_request_out_node.add_item(answer_node)
                except Exception as ex:
                    self.entity.log.error("PLATFORMREQ: seems that request is not valid (%s) %s" % (str(ex), str(item)))
    
    
    
    ### XMPP Management
    
    def process_iq(self, conn, iq):
        """
        this method is invoked when a ARCHIPEL_NS_PLATFORM IQ is received.
        
        it understands IQ of type:
            - allocvm
            
        @type conn: xmpp.Dispatcher
        @param conn: ths instance of the current connection that send the stanza
        @type iq: xmpp.Protocol.Iq
        @param iq: the received IQ
        """
        reply = None
        action = self.entity.check_acp(conn, iq)
        self.entity.check_perm(conn, iq, action, -1, prefix="platform_")
        
        if action == "allocvm":   reply = self.iq_allocvm(iq)
        
        if reply:
            conn.send(reply)
            raise xmpp.protocol.NodeProcessed    
    
    
    def iq_allocvm(self, iq):
        """
        alloc a new VM on the hypervisor
        
        @type iq: xmpp.Protocol.Iq
        @param iq: the received IQ

        @rtype: xmpp.Protocol.Iq
        @return: a ready to send IQ containing the result of the action
        """
        try:
            reply = iq.buildReply("result")
            self.entity.alloc(requester=iq.getFrom(), requested_name=None)
        except Exception as ex:
            reply = build_error_iq(self, ex, iq)
        return reply
    

