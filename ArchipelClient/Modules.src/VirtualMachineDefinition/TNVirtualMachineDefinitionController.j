/*
 * TNViewHypervisorControl.j
 *
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <LPKit/LPKit.j>

@import "TNDriveObject.j";
@import "TNNetworkInterfaceObject.j"
@import "TNDriveController.j";
@import "TNNetworkController.j";

TNArchipelTypeVirtualMachineControl                 = @"archipel:vm:control";
TNArchipelTypeVirtualMachineDefinition              = @"archipel:vm:definition";

TNArchipelTypeVirtualMachineControlXMLDesc          = @"xmldesc";
TNArchipelTypeVirtualMachineDefinitionDefine        = @"define";
TNArchipelTypeVirtualMachineDefinitionUndefine      = @"undefine";
TNArchipelTypeVirtualMachineDefinitionCapabilities  = @"capabilities";

TNArchipelPushNotificationDefinitition              = @"archipel:push:virtualmachine:definition";

VIR_DOMAIN_NOSTATE          =   0;
VIR_DOMAIN_RUNNING          =   1;
VIR_DOMAIN_BLOCKED          =   2;
VIR_DOMAIN_PAUSED           =   3;
VIR_DOMAIN_SHUTDOWN         =   4;
VIR_DOMAIN_SHUTOFF          =   5;
VIR_DOMAIN_CRASHED          =   6;

TNXMLDescBootHardDrive      = @"hd";
TNXMLDescBootCDROM          = @"cdrom";
TNXMLDescBootNetwork        = @"network";
TNXMLDescBootFileDescriptor = @"fd";
TNXMLDescBoots              = [ TNXMLDescBootHardDrive, TNXMLDescBootCDROM,
                                TNXMLDescBootNetwork, TNXMLDescBootFileDescriptor];


TNXMLDescHypervisorKVM          = @"kvm";
TNXMLDescHypervisorXen          = @"xen";
TNXMLDescHypervisorOpenVZ       = @"openvz";
TNXMLDescHypervisorQemu         = @"qemu";
TNXMLDescHypervisorKQemu        = @"kqemu";
TNXMLDescHypervisorLXC          = @"lxc";
TNXMLDescHypervisorUML          = @"uml";
TNXMLDescHypervisorVBox         = @"vbox";
TNXMLDescHypervisorVMWare       = @"vmware";
TNXMLDescHypervisorOpenNebula   = @"one";

TNXMLDescVNCKeymapFR            = @"fr";
TNXMLDescVNCKeymapEN_US         = @"en-us";
TNXMLDescVNCKeymaps             = [TNXMLDescVNCKeymapEN_US, TNXMLDescVNCKeymapFR];


TNXMLDescLifeCycleDestroy           = @"destroy";
TNXMLDescLifeCycleRestart           = @"restart";
TNXMLDescLifeCyclePreserve          = @"preserve";
TNXMLDescLifeCycleRenameRestart     = @"rename-restart";
TNXMLDescLifeCycles                 = [TNXMLDescLifeCycleDestroy, TNXMLDescLifeCycleRestart,
                                        TNXMLDescLifeCyclePreserve, TNXMLDescLifeCycleRenameRestart];

TNXMLDescFeaturePAE                 = @"pae";
TNXMLDescFeatureACPI                = @"acpi";
TNXMLDescFeatureAPIC                = @"apic";

TNXMLDescClockUTC       = @"utc";
TNXMLDescClockLocalTime = @"localtime";
TNXMLDescClockTimezone  = @"timezone";
TNXMLDescClockVariable  = @"variable";
TNXMLDescClocks         = [TNXMLDescClockUTC, TNXMLDescClockLocalTime];

TNXMLDescInputTypeMouse     = @"mouse";
TNXMLDescInputTypeTablet    = @"tablet";
TNXMLDescInputTypes         = [TNXMLDescInputTypeMouse, TNXMLDescInputTypeTablet];

/*! @defgroup  virtualmachinedefinition Module VirtualMachine Definition
    @desc Allow to define virtual machines
*/

/*! @ingroup virtualmachinedefinition
    main class of the module
*/
@implementation VirtualMachineDefinitionController : TNModule
{
    @outlet CPButton                buttonAddNic;
    @outlet CPButton                buttonArchitecture;
    @outlet CPButton                buttonClocks;
    @outlet CPButton                buttonDelNic;
    @outlet CPButton                buttonHypervisor;
    @outlet CPButton                buttonOnCrash;
    @outlet CPButton                buttonOnPowerOff;
    @outlet CPButton                buttonOnReboot;
    @outlet CPButton                buttonXMLEditor;
    @outlet CPButton                buttonUndefine;
    @outlet CPButtonBar             buttonBarControlDrives;
    @outlet CPButtonBar             buttonBarControlNics;
    @outlet CPPopUpButton           buttonBoot;
    @outlet CPPopUpButton           buttonInputType;
    @outlet CPPopUpButton           buttonMachines;
    @outlet TNTextFieldStepper      stepperNumberCPUs;
    @outlet CPPopUpButton           buttonOSType;
    @outlet CPPopUpButton           buttonPreferencesBoot;
    @outlet CPPopUpButton           buttonPreferencesClockOffset;
    @outlet CPPopUpButton           buttonPreferencesInput;
    @outlet CPPopUpButton           buttonPreferencesNumberOfCPUs;
    @outlet CPPopUpButton           buttonPreferencesOnCrash;
    @outlet CPPopUpButton           buttonPreferencesOnPowerOff;
    @outlet CPPopUpButton           buttonPreferencesOnReboot;
    @outlet CPPopUpButton           buttonPreferencesVNCKeyMap;
    @outlet CPPopUpButton           buttonVNCKeymap;
    @outlet CPScrollView            scrollViewForDrives;
    @outlet CPScrollView            scrollViewForNics;
    @outlet CPSearchField           fieldFilterDrives;
    @outlet CPSearchField           fieldFilterNics;
    @outlet CPTabView               tabViewDevices;
    @outlet CPTextField             fieldJID;
    @outlet CPTextField             fieldMemory;
    @outlet CPTextField             fieldName;
    @outlet CPTextField             fieldPreferencesMemory;
    @outlet CPTextField             fieldPreferencesArchitecture;
    @outlet CPTextField             fieldPreferencesEmulator;
    @outlet CPTextField             fieldVNCPassword;
    @outlet CPView                  maskingView;
    @outlet CPView                  viewDeviceVirtualDrives;
    @outlet CPView                  viewDeviceVirtualNics;
    @outlet CPView                  viewDrivesContainer;
    @outlet CPView                  viewNicsContainer;
    @outlet CPWindow                windowXMLEditor;
    @outlet LPMultiLineTextField    fieldStringXMLDesc;
    @outlet TNSwitch                switchACPI;
    @outlet TNSwitch                switchAPIC;
    @outlet TNSwitch                switchHugePages;
    @outlet TNSwitch                switchPAE;
    @outlet TNSwitch                switchPreferencesACPI;
    @outlet TNSwitch                switchPreferencesAPIC;
    @outlet TNSwitch                switchPreferencesHugePages;
    @outlet TNSwitch                switchPreferencesPAE;
    @outlet TNDriveController       driveController;
    @outlet TNNetworkController     networkController;

    CPButton                        _editButtonDrives;
    CPButton                        _editButtonNics;
    CPButton                        _minusButtonDrives;
    CPButton                        _minusButtonNics;
    CPButton                        _plusButtonDrives;
    CPButton                        _plusButtonNics;
    CPColor                         _bezelColor;
    CPColor                         _buttonBezelHighlighted;
    CPColor                         _buttonBezelSelected;
    CPDictionary                    _supportedCapabilities;
    CPString                        _stringXMLDesc;
    CPTableView                     _tableDrives;
    CPTableView                     _tableNetworkNics;
    TNTableViewDataSource           _drivesDatasource;
    TNTableViewDataSource           _nicsDatasource;

}


#pragma mark -
#pragma mark Initialization

/*! called at cib awaking
*/
- (void)awakeFromCib
{
    var bundle      = [CPBundle bundleForClass:[self class]],
        defaults    = [CPUserDefaults standardUserDefaults];

    // this really sucks, but something have change in capp that made the textfield not take care of the Atlas defined values;
    [fieldStringXMLDesc setFrameSize:CPSizeMake(591, 378)];

    // register defaults defaults
    [defaults registerDefaults:[CPDictionary dictionaryWithObjectsAndKeys:
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultNumberCPU"], @"TNDescDefaultNumberCPU",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultMemory"], @"TNDescDefaultMemory",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultBoot"], @"TNDescDefaultBoot",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultVNCKeymap"], @"TNDescDefaultVNCKeymap",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultOnPowerOff"], @"TNDescDefaultOnPowerOff",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultOnReboot"], @"TNDescDefaultOnReboot",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultOnCrash"], @"TNDescDefaultOnCrash",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultClockOffset"], @"TNDescDefaultClockOffset",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultPAE"], @"TNDescDefaultPAE",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultACPI"], @"TNDescDefaultACPI",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultAPIC"], @"TNDescDefaultAPIC",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultHugePages"], @"TNDescDefaultHugePages",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultInputType"], @"TNDescDefaultInputType",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultEmulator"], @"TNDescDefaultEmulator",
            [bundle objectForInfoDictionaryKey:@"TNDescDefaultArchitecture"], @"TNDescDefaultArchitecture"
    ]];

    [fieldJID setSelectable:YES];
    [fieldStringXMLDesc setFont:[CPFont fontWithName:@"Andale Mono, Courier New" size:12]];

    _stringXMLDesc = @"";

    var mainBundle              = [CPBundle mainBundle],
        centerBezel             = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:"TNButtonBar/buttonBarCenterBezel.png"] size:CGSizeMake(1, 26)],
        buttonBezel             = [CPColor colorWithPatternImage:centerBezel],
        centerBezelHighlighted  = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:"TNButtonBar/buttonBarCenterBezelHighlighted.png"] size:CGSizeMake(1, 26)],
        centerBezelSelected     = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:"TNButtonBar/buttonBarCenterBezelSelected.png"] size:CGSizeMake(1, 26)];

    _bezelColor                 = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:"TNButtonBar/buttonBarBackground.png"] size:CGSizeMake(1, 27)]];
    _buttonBezelHighlighted     = [CPColor colorWithPatternImage:centerBezelHighlighted];
    _buttonBezelSelected        = [CPColor colorWithPatternImage:centerBezelSelected];

    _plusButtonDrives   = [CPButtonBar plusButton];
    _minusButtonDrives  = [CPButtonBar minusButton];
    _editButtonDrives   = [CPButtonBar plusButton];

    [_plusButtonDrives setTarget:self];
    [_plusButtonDrives setAction:@selector(addDrive:)];
    [_minusButtonDrives setTarget:self];
    [_minusButtonDrives setAction:@selector(deleteDrive:)];
    [_editButtonDrives setImage:[[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"IconsButtons/edit.png"] size:CPSizeMake(16, 16)]];
    [_editButtonDrives setTarget:self];
    [_editButtonDrives setAction:@selector(editDrive:)];
    [_minusButtonDrives setEnabled:NO];
    [_editButtonDrives setEnabled:NO];
    [buttonBarControlDrives setButtons:[_plusButtonDrives, _minusButtonDrives, _editButtonDrives]];


    _plusButtonNics     = [CPButtonBar plusButton];
    _minusButtonNics    = [CPButtonBar minusButton];
    _editButtonNics     = [CPButtonBar plusButton];

    [_plusButtonNics setTarget:self];
    [_plusButtonNics setAction:@selector(addNetworkCard:)];
    [_minusButtonNics setTarget:self];
    [_minusButtonNics setAction:@selector(deleteNetworkCard:)];
    [_editButtonNics setImage:[[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"IconsButtons/edit.png"] size:CPSizeMake(16, 16)]];
    [_editButtonNics setTarget:self];
    [_editButtonNics setAction:@selector(editNetworkCard:)];
    [_minusButtonNics setEnabled:NO];
    [_editButtonNics setEnabled:NO];
    [buttonBarControlNics setButtons:[_plusButtonNics, _minusButtonNics, _editButtonNics]];


    [viewDrivesContainer setBorderedWithHexColor:@"#C0C7D2"];
    [viewNicsContainer setBorderedWithHexColor:@"#C0C7D2"];

    [networkController setDelegate:self];
    [networkController setDelegate:self];

    //drives
    _drivesDatasource       = [[TNTableViewDataSource alloc] init];
    _tableDrives            = [[CPTableView alloc] initWithFrame:[scrollViewForDrives bounds]];

    [scrollViewForDrives setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [scrollViewForDrives setAutohidesScrollers:YES];
    [scrollViewForDrives setDocumentView:_tableDrives];

    [_tableDrives setUsesAlternatingRowBackgroundColors:YES];
    [_tableDrives setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [_tableDrives setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
    [_tableDrives setAllowsColumnResizing:YES];
    [_tableDrives setAllowsEmptySelection:YES];
    [_tableDrives setAllowsMultipleSelection:YES];
    [_tableDrives setTarget:self];
    [_tableDrives setDelegate:self];
    [_tableDrives setDoubleAction:@selector(editDrive:)];

    var driveColumnType = [[CPTableColumn alloc] initWithIdentifier:@"type"],
        driveColumnDevice = [[CPTableColumn alloc] initWithIdentifier:@"device"],
        driveColumnTarget = [[CPTableColumn alloc] initWithIdentifier:@"target"],
        driveColumnSource = [[CPTableColumn alloc] initWithIdentifier:@"source"],
        driveColumnBus = [[CPTableColumn alloc] initWithIdentifier:@"bus"];

    [[driveColumnType headerView] setStringValue:@"Type"];
    [driveColumnType setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]];

    [[driveColumnDevice headerView] setStringValue:@"Device"];
    [driveColumnDevice setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"device" ascending:YES]];

    [[driveColumnTarget headerView] setStringValue:@"Target"];
    [driveColumnTarget setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"target" ascending:YES]];

    [driveColumnSource setWidth:300];
    [[driveColumnSource headerView] setStringValue:@"Source"];
    [driveColumnSource setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"source" ascending:YES]];

    [[driveColumnBus headerView] setStringValue:@"Bus"];
    [driveColumnBus setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"bus" ascending:YES]];

    [_tableDrives addTableColumn:driveColumnType];
    [_tableDrives addTableColumn:driveColumnDevice];
    [_tableDrives addTableColumn:driveColumnTarget];
    [_tableDrives addTableColumn:driveColumnBus];
    [_tableDrives addTableColumn:driveColumnSource];

    [_drivesDatasource setTable:_tableDrives];
    [_drivesDatasource setSearchableKeyPaths:[@"type", @"device", @"target", @"source", @"bus"]];

    [_tableDrives setDataSource:_drivesDatasource];


    // NICs
    _nicsDatasource      = [[TNTableViewDataSource alloc] init];
    _tableNetworkNics   = [[CPTableView alloc] initWithFrame:[scrollViewForNics bounds]];

    [scrollViewForNics setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [scrollViewForNics setDocumentView:_tableNetworkNics];
    [scrollViewForNics setAutohidesScrollers:YES];

    [_tableNetworkNics setUsesAlternatingRowBackgroundColors:YES];
    [_tableNetworkNics setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [_tableNetworkNics setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
    [_tableNetworkNics setAllowsColumnResizing:YES];
    [_tableNetworkNics setAllowsEmptySelection:YES];
    [_tableNetworkNics setAllowsEmptySelection:YES];
    [_tableNetworkNics setAllowsMultipleSelection:YES];
    [_tableNetworkNics setTarget:self];
    [_tableNetworkNics setDelegate:self];
    [_tableNetworkNics setDoubleAction:@selector(editNetworkCard:)];
    [_tableNetworkNics setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];

    var columnType = [[CPTableColumn alloc] initWithIdentifier:@"type"],
        columnModel = [[CPTableColumn alloc] initWithIdentifier:@"model"],
        columnMac = [[CPTableColumn alloc] initWithIdentifier:@"mac"],
        columnSource = [[CPTableColumn alloc] initWithIdentifier:@"source"];

    [[columnType headerView] setStringValue:@"Type"];
    [columnType setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]];

    [[columnModel headerView] setStringValue:@"Model"];
    [columnModel setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"model" ascending:YES]];

    [columnMac setWidth:150];
    [[columnMac headerView] setStringValue:@"MAC"];
    [columnMac setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"mac" ascending:YES]];

    [[columnSource headerView] setStringValue:@"Source"];
    [columnSource setWidth:250];
    [columnSource setSortDescriptorPrototype:[CPSortDescriptor sortDescriptorWithKey:@"source" ascending:YES]];

    [_tableNetworkNics addTableColumn:columnSource];
    [_tableNetworkNics addTableColumn:columnType];
    [_tableNetworkNics addTableColumn:columnModel];
    [_tableNetworkNics addTableColumn:columnMac];

    [_nicsDatasource setTable:_tableNetworkNics];
    [_nicsDatasource setSearchableKeyPaths:[@"type", @"model", @"mac", @"source"]];

    [_tableNetworkNics setDataSource:_nicsDatasource];

    [fieldFilterDrives setTarget:_drivesDatasource];
    [fieldFilterDrives setAction:@selector(filterObjects:)];
    [fieldFilterNics setTarget:_nicsDatasource];
    [fieldFilterNics setAction:@selector(filterObjects:)];


    // device tabView
    [tabViewDevices setAutoresizingMask:CPViewWidthSizable];
    var tabViewItemDrives = [[CPTabViewItem alloc] initWithIdentifier:@"IDtabViewItemDrives"],
        tabViewItemNics = [[CPTabViewItem alloc] initWithIdentifier:@"IDtabViewItemNics"];

    [tabViewItemDrives setLabel:@"Virtual Medias"];
    [tabViewItemDrives setView:viewDeviceVirtualDrives];
    [tabViewDevices addTabViewItem:tabViewItemDrives];

    [tabViewItemNics setLabel:@"Virtual Nics"];
    [tabViewItemNics setView:viewDeviceVirtualNics];
    [tabViewDevices addTabViewItem:tabViewItemNics];

    // others..
    [buttonBoot removeAllItems];
    [buttonArchitecture removeAllItems];
    [buttonHypervisor removeAllItems];
    [buttonVNCKeymap removeAllItems];
    [buttonMachines removeAllItems];
    [buttonOnPowerOff removeAllItems];
    [buttonOnReboot removeAllItems];
    [buttonOnCrash removeAllItems];
    [buttonClocks removeAllItems];
    [buttonInputType removeAllItems];

    [buttonPreferencesNumberOfCPUs removeAllItems];
    [buttonPreferencesBoot removeAllItems];
    [buttonPreferencesVNCKeyMap removeAllItems];
    [buttonPreferencesOnPowerOff removeAllItems];
    [buttonPreferencesOnReboot removeAllItems];
    [buttonPreferencesOnCrash removeAllItems];
    [buttonPreferencesClockOffset removeAllItems];
    [buttonPreferencesInput removeAllItems];

    [buttonBoot addItemsWithTitles:TNXMLDescBoots];
    [buttonPreferencesBoot addItemsWithTitles:TNXMLDescBoots];

    [buttonPreferencesNumberOfCPUs addItemsWithTitles:[@"1", @"2", @"3", @"4"]];

    [buttonVNCKeymap addItemsWithTitles:TNXMLDescVNCKeymaps];
    [buttonPreferencesVNCKeyMap addItemsWithTitles:TNXMLDescVNCKeymaps];

    [buttonOnPowerOff addItemsWithTitles:TNXMLDescLifeCycles];
    [buttonPreferencesOnPowerOff addItemsWithTitles:TNXMLDescLifeCycles];

    [buttonOnReboot addItemsWithTitles:TNXMLDescLifeCycles];
    [buttonPreferencesOnReboot addItemsWithTitles:TNXMLDescLifeCycles];

    [buttonOnCrash addItemsWithTitles:TNXMLDescLifeCycles];
    [buttonPreferencesOnCrash addItemsWithTitles:TNXMLDescLifeCycles];

    [buttonClocks addItemsWithTitles:TNXMLDescClocks];
    [buttonPreferencesClockOffset addItemsWithTitles:TNXMLDescClocks];

    [buttonInputType addItemsWithTitles:TNXMLDescInputTypes];
    [buttonPreferencesInput addItemsWithTitles:TNXMLDescInputTypes];

    [switchPAE setOn:NO animated:YES sendAction:NO];
    [switchACPI setOn:NO animated:YES sendAction:NO];
    [switchAPIC setOn:NO animated:YES sendAction:NO];

    var menuNet = [[CPMenu alloc] init],
        menuDrive = [[CPMenu alloc] init];

    [menuNet addItemWithTitle:@"Create new network interface" action:@selector(addNetworkCard:) keyEquivalent:@""];
    [menuNet addItem:[CPMenuItem separatorItem]];
    [menuNet addItemWithTitle:@"Edit" action:@selector(editNetworkCard:) keyEquivalent:@""];
    [menuNet addItemWithTitle:@"Delete" action:@selector(deleteNetworkCard:) keyEquivalent:@""];
    [_tableNetworkNics setMenu:menuNet];

    [menuDrive addItemWithTitle:@"Create new drive" action:@selector(addDrive:) keyEquivalent:@""];
    [menuDrive addItem:[CPMenuItem separatorItem]];
    [menuDrive addItemWithTitle:@"Edit" action:@selector(editDrive:) keyEquivalent:@""];
    [menuDrive addItemWithTitle:@"Delete" action:@selector(deleteDrive:) keyEquivalent:@""];
    [_tableDrives setMenu:menuDrive];

    [fieldVNCPassword setSecure:YES];

    _supportedCapabilities = [CPDictionary dictionary];

    [driveController setTable:_tableDrives];
    [networkController setTable:_tableNetworkNics];

    // switch
    [switchAPIC setTarget:self];
    [switchAPIC setAction:@selector(defineXML:)];
    [switchACPI setTarget:self];
    [switchACPI setAction:@selector(defineXML:)];
    [switchPAE setTarget:self];
    [switchPAE setAction:@selector(defineXML:)];
    [switchHugePages setTarget:self];
    [switchHugePages setAction:@selector(defineXML:)];


    //CPUStepper
    [stepperNumberCPUs setMaxValue:4];
    [stepperNumberCPUs setMinValue:1];
    [stepperNumberCPUs setDoubleValue:1];
    [stepperNumberCPUs setValueWraps:NO];
    [stepperNumberCPUs setAutorepeat:NO];
    [stepperNumberCPUs setTarget:self];
    [stepperNumberCPUs setAction:@selector(performCPUStepperClick:)];
}


#pragma mark -
#pragma mark TNModule overrides

/*! called when module is loaded
*/
- (void)willLoad
{
    [super willLoad];

    var center = [CPNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(_didUpdateNickName:) name:TNStropheContactNicknameUpdatedNotification object:_entity];
    [center addObserver:self selector:@selector(_didUpdatePresence:) name:TNStropheContactPresenceUpdatedNotification object:_entity];

    [self registerSelector:@selector(_didReceivePush:) forPushNotificationType:TNArchipelPushNotificationDefinitition];

    [center postNotificationName:TNArchipelModulesReadyNotification object:self];

    [_tableDrives setDelegate:nil];
    [_tableDrives setDelegate:self];
    [_tableNetworkNics setDelegate:nil];
    [_tableNetworkNics setDelegate:self];

    [driveController setDelegate:nil];
    [driveController setDelegate:self];
    [driveController setEntity:_entity];

    [networkController setDelegate:nil];
    [networkController setDelegate:self];
    [networkController setEntity:_entity];

    [self setDefaultValues];

    [fieldStringXMLDesc setStringValue:@""];

    [self getCapabilities];

    // seems to be necessary
    [_tableDrives reloadData];
    [_tableNetworkNics reloadData];
}

/*! called when module is unloaded
*/
- (void)willUnload
{
    [self setDefaultValues];

    [super willUnload];
}

/*! called when module becomes visible
*/
- (BOOL)willShow
{
    if (![super willShow])
        return NO;

    [fieldName setStringValue:[_entity nickname]];
    [fieldJID setStringValue:[_entity JID]];

    [self checkIfRunning];

    return YES;
}

/*! called when module becomes unvisible
*/
- (void)willHide
{
    [super willHide];
}

/*! called when users saves preferences
*/
- (void)savePreferences
{
    var defaults = [CPUserDefaults standardUserDefaults];

    [defaults setObject:[fieldPreferencesMemory intValue] forKey:@"TNDescDefaultMemory"];
    [defaults setObject:[buttonPreferencesNumberOfCPUs title] forKey:@"TNDescDefaultNumberCPU"];
    [defaults setObject:[buttonPreferencesBoot title] forKey:@"TNDescDefaultBoot"];
    [defaults setObject:[buttonPreferencesVNCKeyMap title] forKey:@"TNDescDefaultVNCKeymap"];
    [defaults setObject:[buttonPreferencesOnPowerOff title] forKey:@"TNDescDefaultOnPowerOff"];
    [defaults setObject:[buttonPreferencesOnReboot title] forKey:@"TNDescDefaultOnReboot"];
    [defaults setObject:[buttonPreferencesOnCrash title] forKey:@"TNDescDefaultOnCrash"];
    [defaults setObject:[buttonPreferencesClockOffset title] forKey:@"TNDescDefaultClockOffset"];
    [defaults setObject:[buttonPreferencesInput title] forKey:@"TNDescDefaultInputType"];
    [defaults setObject:[fieldPreferencesEmulator stringValue] forKey:@"TNDescDefaultEmulator"];
    [defaults setObject:[fieldPreferencesArchitecture stringValue] forKey:@"TNDescDefaultArchitecture"];

    [defaults setBool:[switchPreferencesPAE isOn] forKey:@"TNDescDefaultPAE"];
    [defaults setBool:[switchPreferencesACPI isOn] forKey:@"TNDescDefaultACPI"];
    [defaults setBool:[switchPreferencesAPIC isOn] forKey:@"TNDescDefaultAPIC"];
    [defaults setBool:[switchPreferencesHugePages isOn] forKey:@"TNDescDefaultHugePages"];
}

/*! called when users gets preferences
*/
- (void)loadPreferences
{
    var defaults = [CPUserDefaults standardUserDefaults];

    [fieldPreferencesMemory setIntValue:[defaults objectForKey:@"TNDescDefaultMemory"]];
    [fieldPreferencesArchitecture setIntValue:[defaults objectForKey:@"TNDescDefaultArchitecture"]];
    [fieldPreferencesEmulator setIntValue:[defaults objectForKey:@"TNDescDefaultEmulator"]];
    [buttonPreferencesNumberOfCPUs selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultNumberCPU"]];
    [buttonPreferencesBoot selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultBoot"]];
    [buttonPreferencesVNCKeyMap selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultVNCKeymap"]];
    [buttonPreferencesOnPowerOff selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultOnPowerOff"]];
    [buttonPreferencesOnReboot selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultOnReboot"]];
    [buttonPreferencesOnCrash selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultOnCrash"]];
    [buttonPreferencesClockOffset selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultClockOffset"]];
    [buttonPreferencesInput selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultInputType"]];
    [switchPreferencesPAE setOn:[defaults boolForKey:@"TNDescDefaultPAE"] animated:YES sendAction:NO];
    [switchPreferencesACPI setOn:[defaults boolForKey:@"TNDescDefaultACPI"] animated:YES sendAction:NO];
    [switchPreferencesAPIC setOn:[defaults boolForKey:@"TNDescDefaultAPIC"] animated:YES sendAction:NO];
    [switchPreferencesHugePages setOn:[defaults boolForKey:@"TNDescDefaultHugePages"] animated:YES sendAction:NO];
}

/*! called when MainMenu is ready
*/
- (void)menuReady
{
    [[_menu addItemWithTitle:@"Undefine" action:@selector(undefineXML:) keyEquivalent:@""] setTarget:self];
    [_menu addItem:[CPMenuItem separatorItem]];
    [[_menu addItemWithTitle:@"Add drive" action:@selector(addDrive:) keyEquivalent:@""] setTarget:self];
    [[_menu addItemWithTitle:@"Edit selected drive" action:@selector(editDrive:) keyEquivalent:@""] setTarget:self];
    [_menu addItem:[CPMenuItem separatorItem]];
    [[_menu addItemWithTitle:@"Add network card" action:@selector(addNetworkCard:) keyEquivalent:@""] setTarget:self];
    [[_menu addItemWithTitle:@"Edit selected network card" action:@selector(editNetworkCard:) keyEquivalent:@""] setTarget:self];
    [_menu addItem:[CPMenuItem separatorItem]];
    [[_menu addItemWithTitle:@"Open XML editor" action:@selector(openXMLEditor:) keyEquivalent:@""] setTarget:self];
}

/*! called when permissions changes
*/
- (void)permissionsChanged
{
    [self setControl:fieldMemory enabledAccordingToPermission:@"define"];
    [self setControl:buttonArchitecture enabledAccordingToPermission:@"define"];
    [self setControl:stepperNumberCPUs enabledAccordingToPermission:@"define"];
    [self setControl:buttonBoot enabledAccordingToPermission:@"define"];
    [self setControl:buttonOnPowerOff enabledAccordingToPermission:@"define"];
    [self setControl:buttonOnReboot enabledAccordingToPermission:@"define"];
    [self setControl:buttonOnCrash enabledAccordingToPermission:@"define"];
    [self setControl:switchPAE enabledAccordingToPermission:@"define"];
    [self setControl:switchACPI enabledAccordingToPermission:@"define"];
    [self setControl:switchAPIC enabledAccordingToPermission:@"define"];
    [self setControl:switchHugePages enabledAccordingToPermission:@"define"];
    [self setControl:buttonClocks enabledAccordingToPermission:@"define"];
    [self setControl:buttonInputType enabledAccordingToPermission:@"define"];
    [self setControl:buttonVNCKeymap enabledAccordingToPermission:@"define"];
    [self setControl:fieldVNCPassword enabledAccordingToPermission:@"define"];
    [self setControl:buttonHypervisor enabledAccordingToPermission:@"define"];
    [self setControl:buttonOSType enabledAccordingToPermission:@"define"];
    [self setControl:buttonMachines enabledAccordingToPermission:@"define"];
    [self setControl:buttonXMLEditor enabledAccordingToPermission:@"define"];
    [self setControl:_editButtonNics enabledAccordingToPermission:@"define"];
    [self setControl:_editButtonDrives enabledAccordingToPermission:@"define"];
    [self setControl:_plusButtonNics enabledAccordingToPermission:@"define"];
    [self setControl:_plusButtonDrives enabledAccordingToPermission:@"define"];
    [self setControl:_minusButtonNics enabledAccordingToPermission:@"define"];
    [self setControl:_minusButtonDrives enabledAccordingToPermission:@"define"];
    [self setControl:buttonUndefine enabledAccordingToPermission:@"undefine"];

    if (![self currentEntityHasPermission:@"define"])
    {
        [networkController hideWindow:nil];
        [driveController hideWindow:nil];
    }

    [networkController updateAfterPermissionChanged];
    [driveController updateAfterPermissionChanged];
}


#pragma mark -
#pragma mark Notification handlers

/*! called when entity's nickname changes
    @param aNotification the notification
*/
- (void)_didUpdateNickName:(CPNotification)aNotification
{
    if ([aNotification object] == _entity)
    {
       [fieldName setStringValue:[_entity nickname]]
    }
}

/*! called if entity changes it presence
    @param aNotification the notification
*/
- (void)_didUpdatePresence:(CPNotification)aNotification
{
    [self checkIfRunning];
}

/*! called when an Archipel push is received
    @param somePushInfo CPDictionary containing the push information
*/
- (BOOL)_didReceivePush:(CPDictionary)somePushInfo
{
    var sender  = [somePushInfo objectForKey:@"owner"],
        type    = [somePushInfo objectForKey:@"type"],
        change  = [somePushInfo objectForKey:@"change"],
        date    = [somePushInfo objectForKey:@"date"];

    CPLog.info(@"PUSH NOTIFICATION: from: " + sender + ", type: " + type + ", change: " + change);

    [self getXMLDesc];

    return YES;
}


#pragma mark -
#pragma mark Utilities

/*! generate a random Mac address.
    @return CPString containing a random Mac address
*/
- (CPString)generateMacAddr
{
    var hexTab      = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"],
        dA          = "DE",
        dB          = "AD",
        dC          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)],
        dD          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)],
        dE          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)],
        dF          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)];

    return dA + ":" + dB + ":" + dC + ":" + dD + ":" + dE + ":" + dF;
}

/*! set the default value of all widgets
*/
- (void)setDefaultValues
{
    var defaults    = [CPUserDefaults standardUserDefaults],
        cpu         = [defaults integerForKey:@"TNDescDefaultNumberCPU"],
        mem         = [defaults integerForKey:@"TNDescDefaultMemory"],
        vnck        = [defaults objectForKey:@"TNDescDefaultVNCKeymap"],
        opo         = [defaults objectForKey:@"TNDescDefaultOnPowerOff"],
        or          = [defaults objectForKey:@"TNDescDefaultOnReboot"],
        oc          = [defaults objectForKey:@"TNDescDefaultOnCrash"],
        hp          = [defaults boolForKey:@"TNDescDefaultHugePages"],
        clock       = [defaults objectForKey:@"TNDescDefaultClockOffset"],
        pae         = [defaults boolForKey:@"TNDescDefaultPAE"],
        acpi        = [defaults boolForKey:@"TNDescDefaultACPI"],
        apic        = [defaults boolForKey:@"TNDescDefaultAPIC"],
        input       = [defaults objectForKey:@"TNDescDefaultInputType"];

    _supportedCapabilities = [CPDictionary dictionary];

    [stepperNumberCPUs setDoubleValue:cpu];
    [fieldMemory setStringValue:@""];
    [fieldVNCPassword setStringValue:@""];
    [buttonVNCKeymap selectItemWithTitle:vnck];
    [buttonOnPowerOff selectItemWithTitle:opo];
    [buttonOnReboot selectItemWithTitle:or];
    [buttonOnCrash selectItemWithTitle:oc];
    [buttonClocks selectItemWithTitle:clock];
    [buttonInputType selectItemWithTitle:input];
    [switchPAE setOn:((pae == 1) ? YES : NO) animated:YES sendAction:NO];
    [switchACPI setOn:((acpi == 1) ? YES : NO) animated:YES sendAction:NO];
    [switchAPIC setOn:((apic == 1) ? YES : NO) animated:YES sendAction:NO];
    [switchHugePages setOn:((hp == 1) ? YES : NO) animated:YES sendAction:NO];

    [buttonMachines removeAllItems];
    [buttonHypervisor removeAllItems];
    [buttonArchitecture removeAllItems];
    [buttonOSType removeAllItems];

    [_nicsDatasource removeAllObjects];
    [_drivesDatasource removeAllObjects];
    [_tableNetworkNics reloadData];
    [_tableDrives reloadData];

}

/*! checks if virtual machine is running. if yes, display the masking view
*/
- (void)checkIfRunning
{
    var XMPPShow = [_entity XMPPShow];

    if (XMPPShow != TNStropheContactStatusBusy)
    {
        if (![maskingView superview])
        {
            [maskingView setFrame:[[self view] bounds]];
            [[self view] addSubview:maskingView];
        }
    }
    else
        [maskingView removeFromSuperview];
}

/*! check if given hypervisor is in given list (hum I think this will be throw away...)
    @param anHypervisor an Hypervisor type
    @param anArray an array of string
*/
- (BOOL)isHypervisor:(CPString)anHypervisor inList:(CPArray)anArray
{
    return [anArray containsObject:anHypervisor];
}


#pragma mark -
#pragma mark Actions

/*! open the manual XML editor
    @param sender the sender of the action
*/
- (IBAction)openXMLEditor:(id)aSender
{
    [windowXMLEditor center];
    [windowXMLEditor makeKeyAndOrderFront:aSender];
}

/*! define XML
    @param sender the sender of the action
*/
- (IBAction)defineXML:(id)aSender
{
    [self defineXML];
}

/*! define XML from the manual editor
    @param sender the sender of the action
*/
- (IBAction)defineXMLString:(id)aSender
{
    [self defineXMLString];
}

/*! undefine virtual machine
    @param sender the sender of the action
*/
- (IBAction)undefineXML:(id)aSender
{
    [self undefineXML];
}

/*! add a network card
    @param sender the sender of the action
*/
- (IBAction)addNetworkCard:(id)aSender
{
    var defaultNic = [TNNetworkInterface networkInterfaceWithType:@"bridge" model:@"pcnet" mac:[self generateMacAddr] source:@"virbr0"];

    [_nicsDatasource addObject:defaultNic];
    [_tableNetworkNics reloadData];
    [self defineXML];
}

/*! open the network editor
    @param sender the sender of the action
*/
- (IBAction)editNetworkCard:(id)aSender
{
    if (![self currentEntityHasPermission:@"define"])
        return;

    if ([[_tableNetworkNics selectedRowIndexes] count] != 1)
    {
         [self addNetworkCard:aSender];
         return;
    }
    var selectedIndex   = [[_tableNetworkNics selectedRowIndexes] firstIndex],
        nicObject       = [_nicsDatasource objectAtIndex:selectedIndex];

    [networkController setNic:nicObject];
    [networkController showWindow:aSender];
}

/*! delete a network card
    @param sender the sender of the action
*/
- (IBAction)deleteNetworkCard:(id)aSender
{
    if (![self currentEntityHasPermission:@"define"])
        return;

    if ([_tableNetworkNics numberOfSelectedRows] <= 0)
    {
         [TNAlert showAlertWithMessage:@"Error" informative:@"You must select a network interface"];
         return;
    }

     var selectedIndexes = [_tableNetworkNics selectedRowIndexes];

     [_nicsDatasource removeObjectsAtIndexes:selectedIndexes];

     [_tableNetworkNics reloadData];
     [_tableNetworkNics deselectAll];
     [self defineXML];
}

/*! add a drive
    @param sender the sender of the action
*/
- (IBAction)addDrive:(id)aSender
{
    if (![self currentEntityHasPermission:@"define"])
        return;

    var defaultDrive = [TNDrive driveWithType:@"file" device:@"disk" source:"/drives/drive.img" target:@"hda" bus:@"ide"];

    [_drivesDatasource addObject:defaultDrive];
    [_tableDrives reloadData];
    [self defineXML];
}

/*! open the drive editor
    @param sender the sender of the action
*/
- (IBAction)editDrive:(id)aSender
{
    if (![self currentEntityHasPermission:@"define"])
        return;

    if ([[_tableDrives selectedRowIndexes] count] != 1)
    {
         [self addDrive:aSender];
         return;
    }

    var selectedIndex   = [[_tableDrives selectedRowIndexes] firstIndex],
        driveObject     = [_drivesDatasource objectAtIndex:selectedIndex];

    [driveController setDrive:driveObject];
    [driveController showWindow:aSender];
}

/*! delete a drive
    @param sender the sender of the action
*/
- (IBAction)deleteDrive:(id)aSender
{
    if (![self currentEntityHasPermission:@"define"])
        return;

    if ([_tableDrives numberOfSelectedRows] <= 0)
    {
        [TNAlert showAlertWithMessage:@"Error" informative:@"You must select a drive"];
        return;
    }

     var selectedIndexes = [_tableDrives selectedRowIndexes];

     [_drivesDatasource removeObjectsAtIndexes:selectedIndexes];

     [_tableDrives reloadData];
     [_tableDrives deselectAll];
     [self defineXML];
}

/*! called when CPU stepper is clicked. it will update the text field value and defineXML
*/
- (IBAction)performCPUStepperClick:(id)aSender
{
    var cpu = [stepperNumberCPUs doubleValue];

    [self defineXML];
}

#pragma mark -
#pragma mark XMPP Controls

/*! ask hypervisor for its capabilities
*/
- (void)getCapabilities
{
    var stanza   = [TNStropheStanza iqWithType:@"get"];

    [stanza addChildWithName:@"query" andAttributes:{"xmlns": TNArchipelTypeVirtualMachineDefinition}];
    [stanza addChildWithName:@"archipel" andAttributes:{
        "action": TNArchipelTypeVirtualMachineDefinitionCapabilities}];

    [_entity sendStanza:stanza andRegisterSelector:@selector(_didReceiveXMLCapabilities:) ofObject:self];
}

/*! compute hypervisor capabilities
    @param aStanza TNStropheStanza containing the answer
*/
- (BOOL)_didReceiveXMLCapabilities:(TNStropheStanza)aStanza
{
    if ([aStanza type] == @"result")
    {
        var guests = [aStanza childrenWithName:@"guest"];

        _supportedCapabilities = [CPDictionary dictionary];

        for (var i = 0; i < [guests count]; i++)
        {
            var guest               = [guests objectAtIndex:i],
                osType              = [[guest firstChildWithName:@"os_type"] text],
                arch                = [[guest firstChildWithName:@"arch"] valueForAttribute:@"name"],
                features            = [guest firstChildWithName:@"features"],
                supportNonPAE       = NO,
                supportPAE          = NO,
                supportACPI         = NO,
                supportAPIC         = NO,
                domains             = [guest childrenWithName:@"domain"],
                domainsDict         = [CPDictionary dictionary],
                defaultMachines     = [CPArray array],
                defaultEmulator     = [[[guest firstChildWithName:@"arch"] firstChildWithName:@"emulator"] text],
                defaultMachinesNode = [[guest firstChildWithName:@"arch"] ownChildrenWithName:@"machine"];

            for (var j = 0; j < [defaultMachinesNode count]; j++)
            {
                var machine = [defaultMachinesNode objectAtIndex:j];

                if (![defaultMachinesNode containsObject:[machine text]])
                    [defaultMachines addObject:[machine text]];
            }

            if (domains)
            {
                for (var j = 0; j < [domains count]; j++)
                {
                    var domain          = [domains objectAtIndex:j],
                        machines        = [CPArray array],
                        machinesNode    = [domain childrenWithName:@"machine"],
                        domEmulator     = nil,
                        dict            = [CPDictionary dictionary];

                    if ([domain containsChildrenWithName:@"emulator"])
                        domEmulator = [[domain firstChildWithName:@"emulator"] text];
                    else
                        domEmulator = defaultEmulator;

                    if ([machinesNode count] == 0)
                        machines = defaultMachines;
                    else
                        for (var k = 0; k < [machinesNode count]; k++)
                        {
                            var machine = [machinesNode objectAtIndex:k];

                            [machines addObject:[machine text]];
                        }

                    [dict setObject:domEmulator forKey:@"emulator"];
                    [dict setObject:machines forKey:@"machines"];

                    [domainsDict setObject:dict forKey:[domain valueForAttribute:@"type"]]
                }
            }

            if (features)
            {
                supportNonPAE   = [features containsChildrenWithName:@"pae"];
                supportPAE      = [features containsChildrenWithName:@"nonpae"];
                supportACPI     = [features containsChildrenWithName:@"acpi"];
                supportAPIC     = [features containsChildrenWithName:@"apic"];
            }

            var cap = [CPDictionary dictionaryWithObjectsAndKeys:   supportPAE,         @"PAE",
                                                                    supportNonPAE,      @"NONPAE",
                                                                    supportAPIC,        @"APIC",
                                                                    supportACPI,        @"ACPI",
                                                                    domainsDict,        @"domains",
                                                                    osType,             @"OSType"];

            [_supportedCapabilities setObject:cap forKey:arch];
        }
        CPLog.trace(_supportedCapabilities);
        [self getXMLDesc];
    }
    else
    {
        [self handleIqErrorFromStanza:aStanza];
    }

    return NO;
}

/*! ask hypervisor for its description
*/
- (void)getXMLDesc
{
    var stanza   = [TNStropheStanza iqWithType:@"get"];

    [stanza addChildWithName:@"query" andAttributes:{"xmlns": TNArchipelTypeVirtualMachineControl}];
    [stanza addChildWithName:@"archipel" andAttributes:{
        "action": TNArchipelTypeVirtualMachineControlXMLDesc}];

    [_entity sendStanza:stanza andRegisterSelector:@selector(_didReceiveXMLDesc:) ofObject:self];
}

/*! compute hypervisor description
    @param aStanza TNStropheStanza containing the answer
*/
- (BOOL)_didReceiveXMLDesc:(TNStropheStanza)aStanza
{
    var defaults = [CPUserDefaults standardUserDefaults];

    if ([aStanza type] == @"result")
    {
        var domain          = [aStanza firstChildWithName:@"domain"],
            hypervisor      = [domain valueForAttribute:@"type"],
            memory          = [[domain firstChildWithName:@"currentMemory"] text],
            memoryBacking   = [domain firstChildWithName:@"memoryBacking"],
            arch            = [[[domain firstChildWithName:@"os"] firstChildWithName:@"type"] valueForAttribute:@"arch"],
            machine         = [[[domain firstChildWithName:@"os"] firstChildWithName:@"type"] valueForAttribute:@"machine"],
            vcpu            = [[domain firstChildWithName:@"vcpu"] text],
            boot            = [[domain firstChildWithName:@"boot"] valueForAttribute:@"dev"],
            interfaces      = [domain childrenWithName:@"interface"],
            disks           = [domain childrenWithName:@"disk"],
            graphics        = [domain childrenWithName:@"graphics"],
            onPowerOff      = [domain firstChildWithName:@"on_poweroff"],
            onReboot        = [domain firstChildWithName:@"on_reboot"],
            onCrash         = [domain firstChildWithName:@"on_crash"],
            features        = [domain firstChildWithName:@"features"],
            clock           = [domain firstChildWithName:@"clock"],
            input           = [[domain firstChildWithName:@"input"] valueForAttribute:@"type"],
            capabilities    = [_supportedCapabilities objectForKey:arch];

        //////////////////////////////////////////
        // BASIC SETTINGS
        //////////////////////////////////////////

        // Memory
        [fieldMemory setStringValue:(parseInt(memory) / 1024)];

        // CPUs
        [stepperNumberCPUs setDoubleValue:[vcpu intValue]];

        // button architecture
        [buttonArchitecture removeAllItems];
        [buttonArchitecture addItemsWithTitles:[_supportedCapabilities allKeys]];
        if ([buttonArchitecture indexOfItemWithTitle:arch] == -1)
            if ([[buttonArchitecture itemTitles] containsObject:[defaults objectForKey:@"TNDescDefaultArchitecture"]])
                [buttonArchitecture selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultArchitecture"]];
            else
                [buttonArchitecture selectItemAtIndex:0];
        else
            [buttonArchitecture selectItemWithTitle:arch];

        // button BOOT
        if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorKVM, TNXMLDescHypervisorQemu, TNXMLDescHypervisorKQemu]])
        {
            [self setControl:buttonBoot enabledAccordingToPermission:@"define"];

            if (boot == "cdrom")
                [buttonBoot selectItemWithTitle:TNXMLDescBootCDROM];
            else
                [buttonBoot selectItemWithTitle:TNXMLDescBootHardDrive];
        }
        else
        {
            [self setControl:buttonBoot enabledAccordingToPermission:@"define"];
        }


        //////////////////////////////////////////
        // LIFECYCLE
        //////////////////////////////////////////

        // power Off
        if (onPowerOff)
            [buttonOnPowerOff selectItemWithTitle:[onPowerOff text]];
        else
            [buttonOnPowerOff selectItemWithTitle:@"Default"];

        // reboot
        if (onReboot)
            [buttonOnReboot selectItemWithTitle:[onReboot text]];
        else
            [buttonOnPowerOff selectItemWithTitle:@"Default"];

        // crash
        if (onCrash)
            [buttonOnCrash selectItemWithTitle:[onCrash text]];
        else
            [buttonOnPowerOff selectItemWithTitle:@"Default"];


        //////////////////////////////////////////
        // CONTROLS
        //////////////////////////////////////////

        if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorKVM, TNXMLDescHypervisorQemu, TNXMLDescHypervisorKQemu]])
        {
            [self setControl:fieldVNCPassword enabledAccordingToPermission:@"define"];
            [self setControl:buttonVNCKeymap enabledAccordingToPermission:@"define"];

            for (var i = 0; i < [graphics count]; i++)
            {
                var graphic = [graphics objectAtIndex:i];

                if ([graphic valueForAttribute:@"type"] == "vnc")
                {
                    var keymap = [graphic valueForAttribute:@"keymap"];

                    if (keymap)
                        [buttonVNCKeymap selectItemWithTitle:keymap];

                    var passwd = [graphic valueForAttribute:@"passwd"];

                    if (passwd)
                        [fieldVNCPassword setStringValue:passwd];
                }
            }
        }
        else
        {
            [fieldVNCPassword setEnabled:NO];
            [buttonVNCKeymap setEnabled:NO];
        }

        //input type
        if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorKVM, TNXMLDescHypervisorQemu, TNXMLDescHypervisorKQemu]])
        {
            [self setControl:buttonInputType enabledAccordingToPermission:@"define"];

            [buttonInputType selectItemWithTitle:input];
        }
        else
        {
            [buttonInputType setEnabled:NO];
        }


        //////////////////////////////////////////
        // HYPERVISOR
        //////////////////////////////////////////

        // button Hypervisor
        [buttonHypervisor removeAllItems];
        [buttonHypervisor addItemsWithTitles:[[capabilities objectForKey:@"domains"] allKeys]];
        if ([buttonHypervisor indexOfItemWithTitle:hypervisor] == -1)
            if ([[buttonHypervisor itemTitles] containsObject:[defaults objectForKey:@"TNDescDefaultEmulator"]])
                [buttonHypervisor selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultEmulator"]];
            else
                [buttonHypervisor selectItemAtIndex:0];
        else
            [buttonHypervisor selectItemWithTitle:hypervisor];

        // button Machine
        [buttonMachines removeAllItems];
        if ([[[capabilities objectForKey:@"domains"] objectForKey:hypervisor] containsKey:@"machines"] &&
            [[[[capabilities objectForKey:@"domains"] objectForKey:hypervisor] objectForKey:@"machines"] count])
        {
            [self setControl:buttonMachines enabledAccordingToPermission:@"define"];
            [buttonMachines addItemsWithTitles:[[[capabilities objectForKey:@"domains"] objectForKey:hypervisor] objectForKey:@"machines"]];
            if ([buttonMachines indexOfItemWithTitle:machine] == -1)
                [buttonMachines selectItemAtIndex:0];
            else
                [buttonMachines selectItemWithTitle:machine];
        }
        else
            [buttonMachines setEnabled:NO];

        // button OStype
        [buttonOSType removeAllItems];
        [buttonOSType addItemWithTitle:[capabilities objectForKey:@"OSType"]];


        //////////////////////////////////////////
        // ADVANCED FEATURES
        //////////////////////////////////////////

        // APIC
        [switchAPIC setEnabled:NO];
        [switchAPIC setOn:NO animated:YES sendAction:NO];
        if ([capabilities containsKey:@"APIC"] && [capabilities objectForKey:@"APIC"])
        {
            [self setControl:switchAPIC enabledAccordingToPermission:@"define"];

            if (features && [features containsChildrenWithName:TNXMLDescFeatureAPIC])
                [switchAPIC setOn:YES animated:YES sendAction:NO];
        }

        // ACPI
        [switchACPI setEnabled:NO];
        [switchACPI setOn:NO animated:YES sendAction:NO];
        if ([capabilities containsKey:@"ACPI"] && [capabilities objectForKey:@"ACPI"])
        {
            [self setControl:switchACPI enabledAccordingToPermission:@"define"];

            if (features && [features containsChildrenWithName:TNXMLDescFeatureACPI])
                [switchACPI setOn:YES animated:YES sendAction:NO];
        }

        // PAE
        [switchPAE setEnabled:NO];
        [switchPAE setOn:NO animated:YES sendAction:NO];

        if ([capabilities containsKey:@"PAE"] && ![capabilities containsKey:@"NONPAE"])
        {
            [switchPAE setOn:YES animated:YES sendAction:NO];
        }
        else if (![capabilities containsKey:@"PAE"] && [capabilities containsKey:@"NONPAE"])
        {
            [switchPAE setOn:NO animated:YES sendAction:NO];
        }
        else if ([capabilities containsKey:@"PAE"] && [capabilities objectForKey:@"PAE"]
            && [capabilities containsKey:@"NONPAE"] && [capabilities objectForKey:@"NONPAE"])
        {
            [self setControl:switchPAE enabledAccordingToPermission:@"define"];
            if (features && [features containsChildrenWithName:TNXMLDescFeaturePAE])
                [switchPAE setOn:YES animated:YES sendAction:NO];
        }

        // huge pages
        [switchHugePages setOn:NO animated:YES sendAction:NO];
        if (memoryBacking)
        {
            if ([memoryBacking containsChildrenWithName:@"hugepages"])
                [switchHugePages setOn:YES animated:YES sendAction:NO];
        }

        //clock
        if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorKVM, TNXMLDescHypervisorQemu, TNXMLDescHypervisorKQemu, TNXMLDescHypervisorLXC]])
        {
            [self setControl:buttonClocks enabledAccordingToPermission:@"define"];

            if (clock)
                [buttonClocks selectItemWithTitle:[clock valueForAttribute:@"offset"]];
        }
        else
            [buttonClocks setEnabled:NO];


        //////////////////////////////////////////
        // MANUAL
        //////////////////////////////////////////

        // field XML
        _stringXMLDesc  = [[aStanza firstChildWithName:@"domain"] stringValue];
        if (_stringXMLDesc)
        {
            _stringXMLDesc      = _stringXMLDesc.replace("\n  \n", "\n");
            _stringXMLDesc      = _stringXMLDesc.replace("xmlns='http://www.gajim.org/xmlns/undeclared' ", "");
            [fieldStringXMLDesc setStringValue:_stringXMLDesc];
        }


        //////////////////////////////////////////
        // DRIVES
        //////////////////////////////////////////
        [_drivesDatasource removeAllObjects];
        for (var i = 0; i < [disks count]; i++)
        {
            var currentDisk = [disks objectAtIndex:i],
                iType       = [currentDisk valueForAttribute:@"type"],
                iDevice     = [currentDisk valueForAttribute:@"device"],
                iTarget     = [[currentDisk firstChildWithName:@"target"] valueForAttribute:@"dev"],
                iBus        = [[currentDisk firstChildWithName:@"target"] valueForAttribute:@"bus"],
                iSource     = (iType == @"file") ? [[currentDisk firstChildWithName:@"source"] valueForAttribute:@"file"] : [[currentDisk firstChildWithName:@"source"] valueForAttribute:@"dev"],
                newDrive    =  [TNDrive driveWithType:iType device:iDevice source:iSource target:iTarget bus:iBus];

            [_drivesDatasource addObject:newDrive];
        }

        [_tableDrives reloadData];

        // THE dirty temporary solution (instead of beer)
        setTimeout(function(){[_tableDrives setNeedsLayout]; [_tableDrives setNeedsDisplay:YES]}, 1000);


        //////////////////////////////////////////
        // NICS
        //////////////////////////////////////////
        [_nicsDatasource removeAllObjects];
        for (var i = 0; i < [interfaces count]; i++)
        {
            var currentInterface    = [interfaces objectAtIndex:i],
                iType               = [currentInterface valueForAttribute:@"type"],
                iModel              = ([currentInterface firstChildWithName:@"model"]) ? [[currentInterface firstChildWithName:@"model"] valueForAttribute:@"type"] : @"pcnet",
                iMac                = [[currentInterface firstChildWithName:@"mac"] valueForAttribute:@"address"],
                iSource             = (iType == "bridge") ? [[currentInterface firstChildWithName:@"source"] valueForAttribute:@"bridge"] : [[currentInterface firstChildWithName:@"source"] valueForAttribute:@"network"],
                newNic              = [TNNetworkInterface networkInterfaceWithType:iType model:iModel mac:iMac source:iSource];

            [_nicsDatasource addObject:newNic];
        }
        [_tableNetworkNics reloadData];
    }
    else if ([aStanza type] == @"error")
    {
        if ([[[aStanza firstChildWithName:@"error"] firstChildWithName:@"text"] text] == "not-defined")
        {
            [switchAPIC setEnabled:NO];
            [switchACPI setEnabled:NO];
            [switchPAE setEnabled:NO];

            [buttonArchitecture removeAllItems];
            [buttonArchitecture addItemsWithTitles:[_supportedCapabilities allKeys]];
            if ([[buttonArchitecture itemTitles] containsObject:[defaults objectForKey:@"TNDescDefaultArchitecture"]])
                [buttonArchitecture selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultArchitecture"]];
            else
                [buttonArchitecture selectItemAtIndex:0];

            var capabilities = [_supportedCapabilities objectForKey:[buttonArchitecture title]];

            [buttonOSType removeAllItems];
            [buttonOSType addItemWithTitle:[capabilities objectForKey:@"OSType"]];
            [buttonOSType selectItemAtIndex:0];

            CPLog.trace(capabilities);

            [buttonHypervisor setEnabled:NO];
            [buttonHypervisor removeAllItems];

            if ([capabilities containsKey:@"domains"])
            {
                [buttonHypervisor addItemsWithTitles:[[capabilities objectForKey:@"domains"] allKeys]];
                if ([[buttonHypervisor itemTitles] containsObject:[defaults objectForKey:@"TNDescDefaultEmulator"]])
                    [buttonHypervisor selectItemWithTitle:[defaults objectForKey:@"TNDescDefaultEmulator"]];
                else
                    [buttonHypervisor selectItemAtIndex:0];
                [self setControl:buttonHypervisor enabledAccordingToPermission:@"define"];
            }

            [buttonMachines setEnabled:NO];
            [buttonMachines removeAllItems];
            if ([capabilities containsKey:@"domains"] && [[[[capabilities objectForKey:@"domains"] objectForKey:[buttonHypervisor title]] objectForKey:@"machines"] count] > 0)
            {
                [buttonMachines addItemsWithTitles:[[[capabilities objectForKey:@"domains"] objectForKey:[buttonHypervisor title]] objectForKey:@"machines"]];
                [buttonMachines selectItemAtIndex:0];
                [self setControl:buttonMachines enabledAccordingToPermission:@"define"];
            }
        }
        else
        {
            [self handleIqErrorFromStanza:aStanza];
        }
    }

    return NO;
}

/*! ask hypervisor to define XML
*/
- (void)defineXML
{
    var uid             = [[[TNStropheIMClient defaultClient] connection] getUniqueId],
        memory          = "" + [fieldMemory intValue] * 1024 + "",
        arch            = [buttonArchitecture title],
        machine         = [buttonMachines title],
        hypervisor      = [buttonHypervisor title],
        nCPUs           = [stepperNumberCPUs doubleValue],
        boot            = [buttonBoot title],
        nics            = [_nicsDatasource content],
        drives          = [_drivesDatasource content],
        OSType          = [buttonOSType title],
        VNCKeymap       = [buttonVNCKeymap title],
        VNCPassword     = [fieldVNCPassword stringValue],
        capabilities    = [_supportedCapabilities objectForKey:arch],
        stanza          = [TNStropheStanza iqWithAttributes:{"to": [[_entity JID] full], "id": uid, "type": "set"}];

    [stanza addChildWithName:@"query" andAttributes:{"xmlns": TNArchipelTypeVirtualMachineDefinition}];
    [stanza addChildWithName:@"archipel" andAttributes:{
        "action": TNArchipelTypeVirtualMachineDefinitionDefine}];

    //////////////////////////////////////////
    // COMMON INFORMATION
    //////////////////////////////////////////

    [stanza addChildWithName:@"domain" andAttributes:{"type": hypervisor}];

    // name
    [stanza addChildWithName:@"name"];
    [stanza addTextNode:[[_entity JID] node]];
    [stanza up];

    // uuid
    [stanza addChildWithName:@"uuid"];
    [stanza addTextNode:[[_entity JID] node]];
    [stanza up];

    //memory
    [stanza addChildWithName:@"memory"];
    [stanza addTextNode:memory];
    [stanza up];

    // currenrt memory
    [stanza addChildWithName:@"currentMemory"];
    [stanza addTextNode:memory];
    [stanza up];

    if ([switchHugePages isOn])
    {
        [stanza addChildWithName:@"memoryBacking"]
        [stanza addChildWithName:@"hugepages"];
        [stanza up];
        [stanza up];
    }

    // cpu
    [stanza addChildWithName:@"vcpu"];
    [stanza addTextNode:@"" + nCPUs + @""];
    [stanza up];

    //////////////////////////////////////////
    // OS PART
    //////////////////////////////////////////

    [stanza addChildWithName:@"os"];
    if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorLXC]])
    {
        [stanza addChildWithName:@"type"];
        [stanza addTextNode:OSType];
        [stanza up];

        // TODO
        [stanza addChildWithName:@"init"];
        [stanza addTextNode:@"/bin/sh"];
        [stanza up];
    }
    else
    {
        [stanza addChildWithName:@"type" andAttributes:{"machine": machine, "arch": arch}]
        [stanza addTextNode:OSType];
        [stanza up];

        [stanza addChildWithName:@"boot" andAttributes:{"dev": boot}]
        [stanza up];
    }
    [stanza up];

    //////////////////////////////////////////
    // POWER MANAGEMENT
    //////////////////////////////////////////
    [stanza addChildWithName:@"on_poweroff"];
    [stanza addTextNode:[buttonOnPowerOff title]];
    [stanza up];

    [stanza addChildWithName:@"on_reboot"];
    [stanza addTextNode:[buttonOnReboot title]];
    [stanza up];

    [stanza addChildWithName:@"on_crash"];
    [stanza addTextNode:[buttonOnCrash title]];
    [stanza up];

    //////////////////////////////////////////
    // FEATURES
    //////////////////////////////////////////
    [stanza addChildWithName:@"features"];

    if ([switchPAE isOn])
    {
        [stanza addChildWithName:TNXMLDescFeaturePAE];
        [stanza up];
    }

    if ([switchACPI isOn])
    {
        [stanza addChildWithName:TNXMLDescFeatureACPI];
        [stanza up];
    }

    if ([switchAPIC isOn])
    {
        [stanza addChildWithName:TNXMLDescFeatureAPIC];
        [stanza up];
    }

    [stanza up];

    //Clock
    if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorKVM, TNXMLDescHypervisorQemu, TNXMLDescHypervisorKQemu, TNXMLDescHypervisorLXC]])
    {
        [stanza addChildWithName:@"clock" andAttributes:{"offset": [buttonClocks title]}];
        [stanza up];
    }


    //////////////////////////////////////////
    // DEVICES
    //////////////////////////////////////////
    [stanza addChildWithName:@"devices"];

    // emulator
    if ([[[capabilities objectForKey:@"domains"] objectForKey:hypervisor] containsKey:@"emulator"])
    {
        var emulator = [[[capabilities objectForKey:@"domains"] objectForKey:hypervisor] objectForKey:@"emulator"];

        [stanza addChildWithName:@"emulator"];
        [stanza addTextNode:emulator];
        [stanza up];
    }

    // drives
    for (var i = 0; i < [drives count]; i++)
    {
        var drive = [drives objectAtIndex:i];

        [stanza addChildWithName:@"disk" andAttributes:{"device": [drive device], "type": [drive type]}];

        if ([[drive source] uppercaseString].indexOf("QCOW2") != -1) // !!!!!! Argh! FIXME!
        {
            [stanza addChildWithName:@"driver" andAttributes:{"type": "qcow2"}];
            [stanza up];
        }
        if ([drive type] == @"file")
            [stanza addChildWithName:@"source" andAttributes:{"file": [drive source]}];
        else if ([drive type] == @"block")
            [stanza addChildWithName:@"source" andAttributes:{"dev": [drive source]}];

        [stanza up];
        [stanza addChildWithName:@"target" andAttributes:{"bus": [drive bus], "dev": [drive target]}];
        [stanza up];
        [stanza up];
    }

    // nics
    for (var i = 0; i < [nics count]; i++)
    {
        var nic     = [nics objectAtIndex:i],
            nicType = [nic type];

        [stanza addChildWithName:@"interface" andAttributes:{"type": nicType}];
        [stanza addChildWithName:@"mac" andAttributes:{"address": [nic mac]}];
        [stanza up];

        [stanza addChildWithName:@"model" andAttributes:{"type": [nic model]}];
        [stanza up];

        if (nicType == @"bridge")
            [stanza addChildWithName:@"source" andAttributes:{"bridge": [nic source]}];
        else
            [stanza addChildWithName:@"source" andAttributes:{"network": [nic source]}];

        [stanza up];
        [stanza up];
    }


    //////////////////////////////////////////
    // CONTROLS
    //////////////////////////////////////////
    if ([self isHypervisor:hypervisor inList:[TNXMLDescHypervisorKVM, TNXMLDescHypervisorQemu, TNXMLDescHypervisorKQemu, TNXMLDescHypervisorXen]])
    {
        if (![self isHypervisor:hypervisor inList:[TNXMLDescHypervisorXen]])
        {
            [stanza addChildWithName:@"input" andAttributes:{"bus": @"usb", "type": [buttonInputType title]}];
            [stanza up];
        }

        if ([fieldVNCPassword stringValue] != @"")
        {
            [stanza addChildWithName:@"graphics" andAttributes:{
                "autoport": "yes",
                "type": "vnc",
                "port": "-1",
                "keymap": VNCKeymap,
                "passwd": VNCPassword}];
            [stanza up];
        }
        else
        {
            [stanza addChildWithName:@"graphics" andAttributes:{
                "autoport": "yes",
                "type": "vnc",
                "port": "-1",
                "keymap": VNCKeymap}];
            [stanza up];
        }
    }

    //devices up
    [stanza up];

    // send stanza
    [_entity sendStanza:stanza andRegisterSelector:@selector(_didDefineXML:) ofObject:self withSpecificID:uid];
}

/*! ask hypervisor to define XML from string
*/
- (void)defineXMLString
{
    var desc        = (new DOMParser()).parseFromString(unescape(""+[fieldStringXMLDesc stringValue]+""), "text/xml").getElementsByTagName("domain")[0],
        stanza      = [TNStropheStanza iqWithType:@"get"],
        descNode    = [TNXMLNode nodeWithXMLNode:desc];

    [stanza addChildWithName:@"query" andAttributes:{"xmlns": TNArchipelTypeVirtualMachineDefinition}];
    [stanza addChildWithName:@"archipel" andAttributes:{"action": TNArchipelTypeVirtualMachineDefinitionDefine}];
    [stanza addNode:descNode];

    [self sendStanza:stanza andRegisterSelector:@selector(_didDefineXML:)];
    [windowXMLEditor close];
}

/*! compute hypervisor answer about the definition
    @param aStanza TNStropheStanza containing the answer
*/
- (BOOL)_didDefineXML:(TNStropheStanza)aStanza
{
    var responseType    = [aStanza type],
        responseFrom    = [aStanza from];

    if (responseType == @"result")
    {
        CPLog.info(@"Definition of virtual machine " + [_entity nickname] + " sucessfuly updated")
    }
    else if (responseType == @"error")
    {
        [self handleIqErrorFromStanza:aStanza];
    }

    return NO;
}

/*! ask hypervisor to undefine virtual machine. but before ask for a confirmation
*/
- (void)undefineXML
{
        var alert = [TNAlert alertWithMessage:@"Are you sure you want to undefine this virtual machine ?"
                                informative:@"All your changes will be definitly lost."
                                     target:self
                                     actions:[["Undefine", @selector(performUndefineXML:)], ["Cancel", nil]]];
        [alert runModal];
}

/*! ask hypervisor to undefine virtual machine
*/
- (void)performUndefineXML:(id)someUserInfo
{
    var stanza   = [TNStropheStanza iqWithType:@"get"];

    [stanza addChildWithName:@"query" andAttributes:{"xmlns": TNArchipelTypeVirtualMachineDefinition}];
    [stanza addChildWithName:@"archipel" andAttributes:{"action": TNArchipelTypeVirtualMachineDefinitionUndefine}];

    [_entity sendStanza:stanza andRegisterSelector:@selector(didUndefineXML:) ofObject:self];
}

/*! compute hypervisor answer about the undefinition
    @param aStanza TNStropheStanza containing the answer
*/
- (BOOL)didUndefineXML:(TNStropheStanza)aStanza
{
    if ([aStanza type] == @"result")
    {
        [[TNGrowlCenter defaultCenter] pushNotificationWithTitle:@"Virtual machine" message:@"Virtual machine has been undefined"];
        [self getXMLDesc];
    }
    else if ([aStanza type] == @"error")
    {
        [self handleIqErrorFromStanza:aStanza];
    }

    return NO;
}


#pragma mark -
#pragma mark Delegates

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    [_minusButtonDrives setEnabled:NO];
    [_editButtonDrives setEnabled:NO];

    if ([aNotification object] == _tableDrives)
    {
        if ([[aNotification object] numberOfSelectedRows] > 0)
        {
            [self setControl:_minusButtonDrives enabledAccordingToPermission:@"define"];
            [self setControl:_editButtonDrives enabledAccordingToPermission:@"define"];
        }
    }
    else if ([aNotification object] == _tableNetworkNics)
    {
        if ([[aNotification object] numberOfSelectedRows] > 0)
        {
            [self setControl:_minusButtonDrives enabledAccordingToPermission:@"define"];
            [self setControl:_editButtonDrives enabledAccordingToPermission:@"define"];
        }
    }
}

@end