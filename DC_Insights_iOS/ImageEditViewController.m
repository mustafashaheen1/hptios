//
//  ImageEditViewController.m
//  Insights
//
//  Created by Shyam Ashok on 10/21/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ImageEditViewController.h"
#import "DCPathButton.h"
#import "SDToolSettings.h"
#import "UIImage+Tint.h"
#import "NSString+UUID.h"
#import "SDDrawingLayer.h"
#import "NSFileManager+DirectoryInfo.h"
#import "NSString+FileSize.h"
#import "SDPhotoTool.h"
#import "SDPenTool.h"
#import "SDBrushTool.h"
#import "SDLineTool.h"
#import "SDRectangleStrokeTool.h"
#import "SDRectangleFillTool.h"
#import "SDEllipseFillTool.h"
#import "SDEllipseStrokeTool.h"
#import "SDTextTool.h"
#import "SDFillTool.h"
#import "SDEraserTool.h"
#import "User.h"
#import <sys/utsname.h>
#define Brush @"Brush"
#define Pen @"Pen"
#define Line @"Line"
#define Text @"Text"
#define Rectangle @"Rectangle (stroke)"
#define Ellipse @"Ellipse (stroke)"

static NSString* const kSDFileLayersFile        =  @"layers.txt";
static NSString* const kSDFileFlatDrawing       =  @"flat.png";
static NSString* const kSDFileDrawingsDirectory =  @"drawings";
static NSString* const kSDFileTitleFile         =  @"title.txt";

@interface ImageEditViewController ()<DCPathButtonDelegate>

#pragma mark - IBOutlets

@property UIView *layerContainerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *drawingToolButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;
@property (weak, nonatomic) IBOutlet UIButton *color1Button;
@property (weak, nonatomic) IBOutlet UIButton *color2Button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *folderViewButton;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *toolTitleLabel;

#pragma mark - Properties

@property (strong) UIPopoverController *popoverControllerLocal;

#pragma mark - Layers handling

@property (strong) NSMutableArray *layers;
@property (readonly, weak) UIImageView *activeImageView;
@property (assign) int activeLayerIndex;

#pragma mark - Tool settings

@property (strong) SDToolSettings *toolSettings;

#pragma mark - Undo stack

@property (assign) int undoStackLocation;
@property (assign) int undoStackCount;

#pragma mark - Tracking touch

@property (assign) CGPoint lastPoint;

#pragma mark - Drawing

@property (assign) BOOL isNewDrawing;
@property (copy) NSString* drawingTitle;

#pragma mark - Drawing tools

@property (strong) SDPhotoTool *photoTool;
@property (strong) NSMutableArray *drawingTools;

@property (strong) DCPathButton* fontSizeButton;

@end

@implementation ImageEditViewController

- (void)viewDidLoad {
    self.pageTitle = @"ImageEditViewController";
    [super viewDidLoad];
    //init the holder UIView to fix the image squeeze issue - DI-2084
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.layerContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.width)];
    
    [self.view addSubview:_layerContainerView];
    [self configureDCToolPathButton];
    [self configureDCColorPathButton];
    //[self configureDCFontSizeButton];
    [self initializeLayers];

    self.toolSettings = [[SDToolSettings alloc] init];
    [self.toolSettings loadFromUserDefaults];
    
    [self updateColorButtons];
    
    [self setupViewBackground];

    [self initializeDrawing];

    [self initializeTools];

    [self updateDrawingToolButton];

    [self updateDrawingToolTitle];

    [self updateFileInfoControls];

    //additional customization of the view via a block
    if (self.customization) {
        self.customization(self);
    }
    [self assignImagesToBAckGround];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cancelInspectionStatusTouched {
    NSLog(@"cancelInspectionStatusTouched");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) configureDCToolPathButton
{
    // Configure center button
    //
    DCPathButton *dcPathButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"chooser-button-tab"]
                                                           hilightedImage:[UIImage imageNamed:@"chooser-button-tab-highlighted"]];
    dcPathButton.delegate = self;
    dcPathButton.tag = 1;
    dcPathButton.toolAh = YES;

    // Configure item buttons
    //
    DCPathItemButton *itemButton_1 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"editor_arrow"]
                                                           highlightedImage:[UIImage imageNamed:@"editor_arrow"]
                                                            backgroundImage:[UIImage imageNamed:@"editor_arrow"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"editor_arrow"]];
    
    DCPathItemButton *itemButton_2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"editor_circle"]
                                                           highlightedImage:[UIImage imageNamed:@"editor_circle"]
                                                            backgroundImage:[UIImage imageNamed:@"editor_circle"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"editor_circle"]];
    
    DCPathItemButton *itemButton_3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"editor_pencil"]
                                                           highlightedImage:[UIImage imageNamed:@"editor_pencil"]
                                                            backgroundImage:[UIImage imageNamed:@"editor_pencil"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"editor_pencil"]];
    
    DCPathItemButton *itemButton_4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"editor_rectangle"]
                                                           highlightedImage:[UIImage imageNamed:@"editoeditor_rectangler_arrow"]
                                                            backgroundImage:[UIImage imageNamed:@"editor_rectangle"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"editor_rectangle"]];
    
    DCPathItemButton *itemButton_5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"editor_text"]
                                                           highlightedImage:[UIImage imageNamed:@"editor_text"]
                                                            backgroundImage:[UIImage imageNamed:@"editor_text"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"editor_text"]];

    
    // Add the item button into the center button
    //
    [dcPathButton addPathItems:@[itemButton_1, itemButton_2, itemButton_3, itemButton_4, itemButton_5]];
    
    // Change the bloom radius
    //
    dcPathButton.bloomRadius = 120.0f;
    
    // Change the DCButton's center
    //
    //NSLog(@"%f %f", self.view.frame.size.width / 2, self.view.frame.size.height - 25.5f);
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    dcPathButton.dcButtonCenter = CGPointMake(win.bounds.size.width / 2, win.bounds.size.height - 100.5f);
    [dcPathButton centerButtonTapped];

    [self.view addSubview:dcPathButton];
    
}

- (void) configureDCColorPathButton
{
    // Configure center button
    //
    DCPathButton *dcPathButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"rainbow-icon.png"]
                                                           hilightedImage:[UIImage imageNamed:@"rainbow-icon.png"]];
    dcPathButton.tag = 2;
    dcPathButton.delegate = self;
    dcPathButton.toolAh = NO;

    // Configure item buttons
    //
    
    DCPathItemButton *itemButton_1 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"blueBox.jpg"]
                                                           highlightedImage:[UIImage imageNamed:@"blueBox.jpg"]
                                                            backgroundImage:[UIImage imageNamed:@"blueBox.jpg"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"blueBox.jpg"]];
    
    DCPathItemButton *itemButton_2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"redBox.jpg"]
                                                           highlightedImage:[UIImage imageNamed:@"redBox.jpg"]
                                                            backgroundImage:[UIImage imageNamed:@"redBox.jpg"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"redBox.jpg"]];
    
    DCPathItemButton *itemButton_3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"whiteBox.jpg"]
                                                           highlightedImage:[UIImage imageNamed:@"whiteBox.jpg"]
                                                            backgroundImage:[UIImage imageNamed:@"whiteBox.jpg"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"whiteBox.jpg"]];
    
    DCPathItemButton *itemButton_4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"greenBox.jpg"]
                                                           highlightedImage:[UIImage imageNamed:@"greenBox.jpg"]
                                                            backgroundImage:[UIImage imageNamed:@"greenBox.jpg"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"greenBox.jpg"]];
    
    DCPathItemButton *itemButton_5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"blackBox.jpg"]
                                                           highlightedImage:[UIImage imageNamed:@"blackBox.jpg"]
                                                            backgroundImage:[UIImage imageNamed:@"blackBox.jpg"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"blackBox.jpg"]];

    

    // Add the item button into the center button
    //
    NSString *sysName = [self deviceName];
    if ([sysName isEqualToString:@"iPhone5,1"]||[sysName isEqualToString:@"iPhone5,2"] ||[sysName isEqualToString:@"iPhone5,3"] || [sysName isEqualToString:@"iPhone5,4"]) {
        [dcPathButton addPathItems:@[itemButton_1, itemButton_2, itemButton_4]];
    } else {
        [dcPathButton addPathItems:@[itemButton_1, itemButton_2, itemButton_3, itemButton_4, itemButton_5]];
    }
    
    // Change the bloom radius
    //
    dcPathButton.bloomRadius = 120.0f;
    
    // Change the DCButton's center
    //
   // NSLog(@"%f %f", self.view.frame.size.width / 2, self.view.frame.size.height - 25.5f);
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    dcPathButton.dcButtonCenter = CGPointMake(win.bounds.size.width - 20, self.view.frame.size.height / 2 /* - 100*/);
    //[dcPathButton centerButtonTapped];
    
    [self.view addSubview:dcPathButton];
    
}

- (void) configureDCFontSizeButton
{
    // Configure center button
    //
    NSLog(@"ImageEditor - settings toolsize is: %d",self.toolSettings.fontSize);
    /*
    if(self.toolSettings.fontSize==0){
    self.fontSizeButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"smallfont.png"]
                                                           hilightedImage:[UIImage imageNamed:@"smallfont.png"]];
    }else if(self.toolSettings.fontSize==50){
        self.fontSizeButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"mediumfont.png"]
                                                        hilightedImage:[UIImage imageNamed:@"mediumfont.png"]];
    }else{
        self.fontSizeButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"largefont.png"]
                                                        hilightedImage:[UIImage imageNamed:@"largefont.png"]];
    }*/
    
    self.fontSizeButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"font_size_chooser.png"]
                                                    hilightedImage:[UIImage imageNamed:@"font_size_chooser.png"]];
    

    self.fontSizeButton.tag = 3;
    self.fontSizeButton.delegate = self;
    self.fontSizeButton.toolAh = NO;
    
    // Configure item buttons
    //
    
    DCPathItemButton *itemButton_1 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"smallfont.png"]
                                                           highlightedImage:[UIImage imageNamed:@"smallfont.png"]
                                                            backgroundImage:[UIImage imageNamed:@"smallfont.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"smallfont.png"]];
    
    DCPathItemButton *itemButton_2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"mediumfont.png"]
                                                           highlightedImage:[UIImage imageNamed:@"mediumfont.png"]
                                                            backgroundImage:[UIImage imageNamed:@"mediumfont.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"mediumfont.png"]];
    
    DCPathItemButton *itemButton_3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"largefont.png"]
                                                           highlightedImage:[UIImage imageNamed:@"largefont.png"]
                                                            backgroundImage:[UIImage imageNamed:@"largefont.png"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"largefont.png"]];
    
    
    // Add the item button into the center button
    //
    NSString *sysName = [self deviceName];
    if ([sysName isEqualToString:@"iPhone5,1"]||[sysName isEqualToString:@"iPhone5,2"] ||[sysName isEqualToString:@"iPhone5,3"] || [sysName isEqualToString:@"iPhone5,4"]) {
        [self.fontSizeButton addPathItems:@[itemButton_1, itemButton_2, itemButton_3]];
    } else {
        [self.fontSizeButton addPathItems:@[itemButton_1, itemButton_2, itemButton_3]];
    }
    
    // Change the bloom radius
    //
    self.fontSizeButton.bloomRadius = 120.0f;
    
    // Change the DCButton's center
    //
    //NSLog(@"%f %f", self.view.frame.size.width / 2, self.view.frame.size.height - 25.5f);
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.fontSizeButton.dcButtonCenter = CGPointMake(win.bounds.size.width - 20, self.view.frame.size.height / 2  - 150);
    //[dcPathButton centerButtonTapped];
    [self.view addSubview:self.fontSizeButton];
    
    //try to dynamically replace the icon
    /*
    NSUInteger z = NSNotFound;
    for(UIView* view in self.view.subviews){
        if(view.tag == 3){
            z =[self.view.subviews indexOfObject:view];
        }
    }
    if (z == NSNotFound)
        [self.view addSubview:self.fontSizeButton];
    else{
    
    UIView *superview = self.fontSizeButton.superview;
        [self.fontSizeButton removeFromSuperview];
        [superview insertSubview:self.fontSizeButton atIndex:z];
    }*/
    
  
}


- (NSString *) deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}


- (void) assignImagesToBAckGround {
    //self.imageViewEdit.image = self.imageForEdit;
    if (self.imageForEdit) {
        self.activeImageView.image = self.imageForEdit;
    } else {
        Image *imageLocal = self.imageObjectForEdit;
        UIImage *image = [imageLocal getImageFromDeviceUrl];
        self.activeImageView.image = image;
    }
    [self addDrawingToUndoStack];
}
/*
-(UIImage*)getImageForEditing{
    if (self.imageForEdit) {
        return self.imageForEdit;
    } else {
        Image *imageLocal = self.imageObjectForEdit;
        UIImage *image = [imageLocal getImageFromDeviceUrl];
        return image;
    }
}
*/
-(void) removeDCFontSizeButton {
    for(UIView *view in self.view.subviews){
        int tag = (int)view.tag;
        if([view isKindOfClass:[DCPathButton class]] && tag==3){
            [view removeFromSuperview];
        }
    }
}

#pragma mark - DCPathButton Delegate

- (void)itemButtonTappedAtIndex:(NSUInteger)index withDCButton: (DCPathButton *) dcPathButton
{
    if (dcPathButton.tag == 1) {
        if (index == 0) {
            self.toolSettings.drawingTool = Line;
        } else if (index == 1) {
            self.toolSettings.drawingTool = Ellipse;
        } else if (index == 2) {
            self.toolSettings.drawingTool = Pen;
        } else if (index == 3) {
            self.toolSettings.drawingTool = Rectangle;
        } else if (index == 4) {
            self.toolSettings.drawingTool = Text;
            [self configureDCFontSizeButton];
        }
        if(index!=4)
        [self removeDCFontSizeButton]; //remove font button
        
        //cancel importing photo
        self.photoTool.photo = nil;
        
        [self updateDrawingToolButton];
        [self updateDrawingToolTitle];
    } else if (dcPathButton.tag == 2){
        NSString *sysName = [self deviceName];
        if ([sysName isEqualToString:@"iPhone5,1"]||[sysName isEqualToString:@"iPhone5,2"] ||[sysName isEqualToString:@"iPhone5,3"] || [sysName isEqualToString:@"iPhone5,4"]) {
            if (index == 0) {
                [self.toolSettings setPrimaryColor: [UIColor blueColor]];
            } else if (index == 1) {
                [self.toolSettings setPrimaryColor: [UIColor redColor]];
            } else if (index == 2) {
                [self.toolSettings setPrimaryColor: [UIColor greenColor]];
            }
        } else {
            if (index == 0) {
                [self.toolSettings setPrimaryColor: [UIColor blueColor]];
            } else if (index == 1) {
                [self.toolSettings setPrimaryColor: [UIColor redColor]];
            } else if (index == 2) {
                [self.toolSettings setPrimaryColor: [UIColor whiteColor]];
            } else if (index == 3) {
                [self.toolSettings setPrimaryColor: [UIColor greenColor]];
            } else if (index == 4) {
                [self.toolSettings setPrimaryColor: [UIColor blackColor]];
            }
        }
    }else if (dcPathButton.tag == 3){
        
        if (index == 0) {
            self.toolSettings.fontSize = 25;
            self.toolSettings.drawingTool = Text;
        } else if (index == 1) {
            self.toolSettings.fontSize = 50;
            self.toolSettings.drawingTool = Text;
        } else if (index == 2) {
            self.toolSettings.fontSize = 75;
            self.toolSettings.drawingTool = Text;
        }
    }
}

- (void)initializeLayers {
    self.layers = [[NSMutableArray alloc] init];
}

- (void)resetUndoStack {
    [self deletePersistedUndoCopies];
    self.undoStackLocation = -1;
    self.undoStackCount = 0;
}

// clear the undo stack contents persisted to file
- (void)deletePersistedUndoCopies {
    NSString *undoFilesDirectory = [self undoFilesDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:undoFilesDirectory error:nil];
}

#pragma mark - Directory paths

- (NSString*)drawingsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString *documentsDirectory = paths[0];
    NSString *drawingsDirectory = [documentsDirectory stringByAppendingPathComponent:kSDFileDrawingsDirectory];
    return drawingsDirectory;
}

- (NSString*)undoFilesDirectory {
    NSString *undoFilesDirectory = [[self photoDirectory] stringByAppendingPathComponent:@"undo"];
    return undoFilesDirectory;
}

- (NSString*)photoDirectory {
    NSString *photoDirectory = [[self drawingsDirectory] stringByAppendingPathComponent:self.drawingID];
    return photoDirectory;
}

#pragma mark - Populating views

- (void)updateFileSizeLabel {
    
    NSString *undoFilesPath = [self undoFilesDirectory];
    NSString *drawingFilesPath = [self photoDirectory];
    
    long fileCount = 0;
    long undoFilesSize = 0;
    long drawingFilesSize = 0;
    [NSFileManager subFileCount:&fileCount andSubFileSize:&undoFilesSize forDirectory:undoFilesPath];
    [NSFileManager subFileCount:&fileCount andSubFileSize:&drawingFilesSize forDirectory:drawingFilesPath];
    
    drawingFilesSize -= undoFilesSize;
    self.fileSizeLabel.text = [NSString stringWithFormat:@"Drawing files: %@, Undo files: %@", [NSString stringWithFileSize:drawingFilesSize], [NSString stringWithFileSize:undoFilesSize]];
}

- (void)setupViewBackground {
    /*UIImage *bgImage = [UIImage imageNamed:@"transparent-checkerboard.png"];
    UIColor *color = [UIColor colorWithPatternImage:bgImage];*/
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)updateColorButtons {
    [self.color1Button setImage:[UIImage imageNamed:@"color-palette-mini-white.png" withTint:self.toolSettings.primaryColor] forState:UIControlStateNormal];
    [self.color2Button setImage:[UIImage imageNamed:@"color-palette-mini-white.png" withTint:self.toolSettings.secondaryColor] forState:UIControlStateNormal];
}

- (void)updateDrawingTitle {
    if (self.drawingTitle.length > 0) {
        [self.titleButton setTitle:self.drawingTitle forState:UIControlStateNormal];
    } else {
        [self.titleButton setTitle:@"Tap to add title" forState:UIControlStateNormal];
    }
}

- (void)updateDrawingToolTitle
{
    self.toolTitleLabel.text = self.toolSettings.drawingTool;
}

- (void)updateFileInfoControls {
    BOOL showFolderViewButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"FILE_SYSTEM_VIEW"];
    if (!showFolderViewButton) {
        [self removeFolderViewButton];
        self.fileSizeLabel.hidden = YES;
    }
}

- (void)removeFolderViewButton {
    NSMutableArray *newToolBarArray = [self.topToolbar.items mutableCopy];
    [newToolBarArray removeObject:self.folderViewButton];
    //[self.topToolbar setItems:[@[newToolBarArray] objectAtIndex:0] animated:NO];
}


- (void)updateDrawingToolButton
{
    SDDrawingTool *tool = [self activeTool];;
    self.drawingToolButton.image = [UIImage imageNamed:tool.imageName];
}

#pragma mark - File handling - Load / Save / Delete drawings

- (void)initializeDrawing {
    
    if (!self.drawingID) {
        
        [self initializeNewDrawing];
        
    } else {
        [self loadDrawingFromID];
    }
    
    [self addDrawingToUndoStack];
    
    [self updateDrawingTitle];
    
}

- (void)initializeNewDrawing {
    self.drawingID = [NSString UUIDString];
    self.isNewDrawing = YES;
    [self addNewLayer];
}

- (void)loadDrawingFromID {
    NSString *photoDirectory = [self photoDirectory];
    [self loadDrawingLayers:photoDirectory];
    [self loadDrawingTitle:photoDirectory];
}

- (void)loadDrawingLayers:(NSString*)photoDirectory {
    
    NSString *layersFileName = [photoDirectory stringByAppendingPathComponent:kSDFileLayersFile];
    
    self.layers = [[NSKeyedUnarchiver unarchiveObjectWithFile:layersFileName] mutableCopy];
    
    [self.layerContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //iterate backward, setupImageViewForLayer will add at an inverted z-order
    for (int i = self.layers.count - 1; i >= 0; i--) {
        
        SDDrawingLayer *layer = self.layers[i];
        
        [self setupImageViewForLayer:layer];
        [self setupLayerVisibility:layer];
        
        NSString *layerImageName = [[photoDirectory stringByAppendingPathComponent:layer.layerID] stringByAppendingPathExtension:@"png"];
        
        //don't load with UIImage directly, causes an error saving as we move these files
        layer.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:layerImageName]];
        
    }
    
}

- (void)loadDrawingTitle:(NSString*)photoDirectory {
    
    NSString *textFilePath = [photoDirectory stringByAppendingPathComponent:kSDFileTitleFile];
    self.drawingTitle = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:textFilePath] encoding:NSUTF8StringEncoding error:nil];
    
}

- (UIImage *)returnDrawingData:(NSString*)photoDirectory saveFlatCopy:(BOOL)saveFlatCopy {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //backup the current drawing files
    NSString *backupPhotoDirectory = [NSString stringWithFormat:@"%@_bak", photoDirectory];
    [fileManager moveItemAtPath:photoDirectory toPath:backupPhotoDirectory error:nil];
    
    [fileManager createDirectoryAtPath:photoDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    [self saveDrawingLayers:photoDirectory];
    [self saveDrawingTitle:photoDirectory];
    UIImage *image = nil;
    if (saveFlatCopy) {
        image = [self drawingImage:[photoDirectory stringByAppendingPathComponent:kSDFileFlatDrawing]];
    }
    
    //delete the backup drawing files now that drawing is saved
    [fileManager removeItemAtPath:backupPhotoDirectory error:nil];
    return image;
}

- (void)saveDrawingToDirectory:(NSString*)photoDirectory saveFlatCopy:(BOOL)saveFlatCopy {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //backup the current drawing files
    NSString *backupPhotoDirectory = [NSString stringWithFormat:@"%@_bak", photoDirectory];
    [fileManager moveItemAtPath:photoDirectory toPath:backupPhotoDirectory error:nil];
    
    [fileManager createDirectoryAtPath:photoDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    [self saveDrawingLayers:photoDirectory];
    [self saveDrawingTitle:photoDirectory];
    
    if (saveFlatCopy) {
        [self saveFlatDrawing:[photoDirectory stringByAppendingPathComponent:kSDFileFlatDrawing]];
    }
    
    //delete the backup drawing files now that drawing is saved
    [fileManager removeItemAtPath:backupPhotoDirectory error:nil];
    
}

- (UIImage *)drawingImage:(NSString*)photoFileName {
    UIImage *flatImage = [self getFlattenedImageOfDrawing];
    return flatImage;
}

- (void)saveFlatDrawing:(NSString*)photoFileName {
    
    UIImage *flatImage = [self getFlattenedImageOfDrawing];
    
    NSData *photoData = UIImagePNGRepresentation(flatImage);
    [photoData writeToFile:photoFileName atomically:YES];
    
}

- (UIImage*)getFlattenedImageOfDrawing {
    
    // create a new bitmap image context
    UIGraphicsBeginImageContextWithOptions(self.layerContainerView.bounds.size, NO, 0.0);
    
    // reversed as the z-order of the layer image views is the reverse of the layers array order
    for (int i = self.layers.count - 1; i >= 0; i--) {
        SDDrawingLayer *layer = (SDDrawingLayer*)self.layers[i];
        if (layer.visible) {
            [layer.imageView.image drawInRect:layer.imageView.bounds blendMode:kCGBlendModeNormal alpha:1.0 - (layer.transparency / 100.0)];
        }
    }
    
    // get a UIImage from the image context
    UIImage *flatImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
    return flatImage;
    
}


- (void)saveDrawingLayers:(NSString*)photoDirectory {
    
    NSString *layersFileName = [photoDirectory stringByAppendingPathComponent:kSDFileLayersFile];
    
    [NSKeyedArchiver archiveRootObject:self.layers toFile:layersFileName];
    
    for (SDDrawingLayer* layer in self.layers) {
        
        NSString *layerImageName = [[photoDirectory stringByAppendingPathComponent:layer.layerID] stringByAppendingPathExtension:@"png"];
        NSData *photoData = UIImagePNGRepresentation(layer.imageView.image);
        [photoData writeToFile:layerImageName atomically:YES];
        
    }
    
}

- (void)saveDrawingTitle:(NSString*)photoDirectory {
    
    NSString *textFilePath = [photoDirectory stringByAppendingPathComponent:kSDFileTitleFile];
    [self.drawingTitle writeToFile:textFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

- (UIImage *) saveCurrentDrawing {
    UIImage *image = [self returnDrawingData:[self photoDirectory] saveFlatCopy:YES];
    return image;
}


#pragma mark - Layer handling

- (UIImageView*)activeImageView {
    
    return ((SDDrawingLayer*)self.layers[self.activeLayerIndex]).imageView;
    
}

- (void)addNewLayer {
    SDDrawingLayer *newLayer = [[SDDrawingLayer alloc] init];
    [self.layers addObject:newLayer];
    [self initializeNewLayer:newLayer];
    self.activeLayerIndex = self.layers.count - 1;
    
}

- (void)initializeNewLayer:(SDDrawingLayer*)layer {
    layer.layerID = [NSString UUIDString];
    layer.layerName = [NSString stringWithFormat:@"Layer #%d", self.layers.count];
    layer.visible = YES;
    [self setupImageViewForLayer:layer];
}

- (void)setupImageViewForLayer:(SDDrawingLayer*)layer {
    UIImageView *layerView = [[UIImageView alloc] initWithFrame:self.layerContainerView.bounds];
    //absolutely necessary - layer may be added in viewDidLoad before frames are final
    //layerView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    layerView.autoresizingMask = UIViewAutoresizingNone;
    //add subview rather than inserting - newly added layers are in front
    [self.layerContainerView addSubview:layerView];
    layer.imageView = layerView;
}

- (void)setupLayerVisibility:(SDDrawingLayer*)layer {
    if (layer.visible) {
        layer.imageView.hidden = NO;
    } else {
        layer.imageView.hidden = YES;
    }
    layer.imageView.alpha = 1.0 - (layer.transparency / 100.00);
}

#pragma mark - Undo stack

// add the current drawing to the undo stack
- (void)addDrawingToUndoStack {
    
    NSString *undoFilesDirectory = [self undoFilesDirectory];
    NSString *undoFileDirectory = [undoFilesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", ++self.undoStackLocation]];
    self.undoStackCount = self.undoStackLocation + 1;
    /* this could be improved by getting copies of the current layers and current
     layer images in local variables and then passing those into a refactored
     save method in the block below
     with the current code, on slower devices, drawing operations that happen in
     quick succession may be undone in one step
     use background priority so this has the least impact on drawing operations*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //this will run on a background thread
        [[NSFileManager defaultManager] createDirectoryAtPath:undoFileDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        [self saveDrawingToDirectory:undoFileDirectory saveFlatCopy:NO];
        //dispatch async to keep UI responsive
        dispatch_async(dispatch_get_main_queue(), ^{
            //this will run on the main thread
            [self updateFileSizeLabel];
        });
    });
}

// load the image for the current undo stack position
- (BOOL)loadImageFromUndoStack {
    NSString *undoFilesDirectory = [self undoFilesDirectory];
    NSString *undoFileDirectory = [undoFilesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", self.undoStackLocation]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:undoFileDirectory]) {
        [self loadDrawingLayers:undoFileDirectory];
        self.activeLayerIndex = 0;
        return YES;
    } else {
        return NO;
    }
    
}

- (void)undoDrawingStep {
    
    if (self.undoStackLocation > 1) {
        self.undoStackLocation--;
        
        if (self.isNewDrawing && (self.undoStackLocation == 0)) {
            //if this is a new drawing and we've undone to location 0, clear the image
            //we don't have a 0.png as we started with an empty drawing
            self.activeImageView.image = nil;
        } else if (![self loadImageFromUndoStack]) {
            //rever to old location if there was no undo image
            self.undoStackLocation++;
        }
    }
    
}

- (void)redoDrawingStep {
    
    if (self.undoStackLocation < self.undoStackCount - 1) {
        self.undoStackLocation++;
        
        if (![self loadImageFromUndoStack]) {
            //rever to old location if there was no undo image
            self.undoStackLocation--;
        }
    }
    
}

#pragma mark - Tools handling

- (BOOL)tracingPhotoDestination {
    return (self.photoTool.photo != nil);
}

- (SDDrawingTool*)activeTool {
    for (SDDrawingTool *tool in self.drawingTools) {
        if ([tool.toolName isEqualToString:self.toolSettings.drawingTool]) {
            return tool;
        }
    }
    return nil;
}


- (void)initializeTools {
    
    
    self.drawingTools = [[NSMutableArray alloc] init];
    
    //pen tool
    SDDrawingTool *tool = [[SDPenTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = Pen;
    tool.imageName = @"pen-ink-mini.png";
    [self.drawingTools addObject:tool];
    
    //brush tool
    tool = [[SDBrushTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = Brush;
    tool.imageName = @"paint-brush-mini.png";
    [self.drawingTools addObject:tool];
    
    //line tool
    tool = [[SDLineTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = Line;
    tool.imageName = @"ruler-triangle-mini.png";
    [self.drawingTools addObject:tool];
    
    //text tool
    tool = [[SDTextTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = Text;
    tool.imageName = @"text-capital-mini.png";
    [self.drawingTools addObject:tool];
    
    //rectangle stroke tool
    tool = [[SDRectangleStrokeTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = Rectangle;
    tool.imageName = @"multiple-mini.png";
    [self.drawingTools addObject:tool];
    
    //rectangle fill tool
    tool = [[SDRectangleFillTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = @"Rectangle (fill)";
    tool.imageName = @"multiple-mini.png";
    [self.drawingTools addObject:tool];
    
    //ellipse stroke tool
    tool = [[SDEllipseStrokeTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = Ellipse;
    tool.imageName = @"circle-mini.png";
    [self.drawingTools addObject:tool];
    
    //ellipse fill tool
    tool = [[SDEllipseFillTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = @"Ellipse (fill)";
    tool.imageName = @"circle-mini.png";
    [self.drawingTools addObject:tool];
    
    //fill tool
    tool = [[SDFillTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = @"Fill (bucket)";
    tool.imageName = @"paint-mini.png";
    [self.drawingTools addObject:tool];
    
    //eraser tool
    tool = [[SDEraserTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    tool.toolName = @"Eraser";
    tool.imageName = @"eraser-mini.png";
    [self.drawingTools addObject:tool];
    
    //photo tool
    self.photoTool = [[SDPhotoTool alloc] initWithCompletion:^{
        
        [self addDrawingToUndoStack];
        
    }];
    
    if (self.toolListCustomization) {
        self.toolListCustomization(self.drawingTools);
    }
    
}

#pragma mark - Touch handling

- (BOOL)shouldTrackTouch:(UITouch*)touch {
    
    //don't track when showing map view
    if (self.presentedViewController) {
        return NO;
    }
    
    CGPoint touchLocation = [touch locationInView:self.layerContainerView];
    if ((touchLocation.y < 0) || (touchLocation.y > self.layerContainerView.frame.size.height)) {
        return NO;
    }
    
    return YES;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //do not respond to touch if the title UITextField is visible
    if (self.titleTextField && !self.titleTextField.hidden) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    if (![self shouldTrackTouch:touch]) {
        return;
    }
    
    if ([self tracingPhotoDestination]) {
        
        [self.photoTool touchBegan:touch inImageView:self.activeImageView withSettings:self.toolSettings];
        
    } else {
        
        SDDrawingTool *drawingTool = [self activeTool];
        if (drawingTool) {
            [drawingTool touchBegan:touch inImageView:self.activeImageView withSettings:self.toolSettings];
        }
        
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //do not respond to touch if the title UITextField is visible
    if (self.titleTextField && !self.titleTextField.hidden) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    if (![self shouldTrackTouch:touch]) {
        return;
    }
    
    if ([self tracingPhotoDestination]) {
        
        [self.photoTool touchMoved:touch];
        
    } else  {
        
        SDDrawingTool *drawingTool = [self activeTool];
        if (drawingTool) {
            [drawingTool touchMoved:touch];
        }
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //do not respond to touch if the title UITextField is visible
    if (self.titleTextField && !self.titleTextField.hidden) {
        //resign first responder status for title UITextField
        [self.titleTextField resignFirstResponder];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if (![self shouldTrackTouch:touch]) {
        return;
    }
    
    if ([self tracingPhotoDestination]) {
        [self.photoTool touchEnded:touch];
    } else {
        SDDrawingTool *drawingTool = [self activeTool];
        if (drawingTool) {
            [drawingTool touchEnded:touch];
        }
    }
}


#pragma mark - Button Taps

- (void) saveButtonTouched {
    UIImage *flattenedImage = [self saveCurrentDrawing];
    if ([self.parentView isEqualToString:kNibContainerViewController]) {
        [[[User sharedUser] allImages] removeObject:self.imageForEdit];
        [[User sharedUser].allImages addObject:flattenedImage];
    } else {
        Image *imageLocal = self.imageObjectForEdit;
        [imageLocal deleteImageFromDevice:imageLocal.path];
        [imageLocal saveImageToDevice:flattenedImage];
    }
    [self.delegate viewControllerDidSaveDrawing:self];
    //clean up memory to avoid leaks
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) undoButtonTouched {
    [self undoDrawingStep];
}

- (void) redoButtonTouched {
    [self redoDrawingStep];
}

@end
