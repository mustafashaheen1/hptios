//
//  VerticalGalleryViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "VerticalGalleryViewController.h"
#import "Image.h"
#import "ImageEditViewController.h"
#import "User.h"
#import "Inspection.h"

#define heightForCell 250

@interface VerticalGalleryViewController ()

@end

@implementation VerticalGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageTitle = @"VerticalGalleryViewController";
    [self setupNavBar];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //[self addContentsToScrollView];
    [self initTableView];
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) initTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setEditing:YES animated:YES];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return heightForCell;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.productView)
    {
        return [self.imagesArray count];
    }else{
        return [self.rawImagesArray count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    int yOffset = 20;
    Image *image;
    UIImage *imageLocal;
    if(self.productView)
    {
        image = [self.imagesArray objectAtIndex:indexPath.row];
        imageLocal = [image getImageFromDeviceUrl];
    }else{
        imageLocal = [self.rawImagesArray objectAtIndex:indexPath.row];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(43, yOffset, 240, 223)];
    if (imageLocal) {
        [imageView setImage:imageLocal];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //imageView.frame = CGRectMake(self.view.frame.size.width/2 + 100, yaxis, 240, 223);
    }
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.borderWidth = 2.0;
    imageView.clipsToBounds = YES;
    imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.tag = indexPath.row;
    
    //DI-2773 - Photo Editing tools dose not show up when trying to edit images
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:singleTap];
    [imageView setUserInteractionEnabled:YES];
    
    UIButton *buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonDelete.frame = CGRectMake(43+223, yOffset-12, 30, 30);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //buttonDelete.frame = CGRectMake(self.view.frame.size.width/2 + 100 + 223, yaxis-12, 30, 30);
    }
    [buttonDelete setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
    [buttonDelete addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    buttonDelete.tag = indexPath.row;
    [cell addSubview:imageView];
    [cell addSubview:buttonDelete];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.imagesArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

- (void) goBack {
    dispatch_queue_t loadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showLoadingScreenWithText:@"Processing..."];
    dispatch_async(loadingQueue, ^{
            [self renameImagesForReorder];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissLoadingScreen];
                [super goBack];
            });
    });
}

-(void)renameImagesForReorder {
    int count = self.imagesArray.count;
    for(int i=0; i<count; i++){
        Image* image = [self.imagesArray objectAtIndex:i];
        NSLog(@"GalleryViewController - Old image is: %@",image.remoteUrl);
        [image updateImagePosition:i];
        NSLog(@"GalleryViewController - New image is: %@",image.remoteUrl);
    }
}

- (void) addContentsToScrollView {
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    int yaxis = 20;
    if (self.productView) {
        for (int i = 0; i < [self.imagesArray count]; i++) {
            Image *image = [self.imagesArray objectAtIndex:i];
            UIImage *imageLocal = [image getImageFromDeviceUrl];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(43, yaxis, 240, 223)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //imageView.frame = CGRectMake(self.view.frame.size.width/2 + 100, yaxis, 240, 223);
            }
            //NSLog(@"%d %d %d %d", 43, yaxis, 240, 223);
            imageView.layer.cornerRadius = 5.0;
            imageView.layer.borderWidth = 2.0;
            imageView.clipsToBounds = YES;
            imageView.layer.borderColor = [[UIColor blackColor] CGColor];
            imageView.backgroundColor = [UIColor blackColor];
            imageView.tag = i;
            
            UIButton *buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonDelete.frame = CGRectMake(43+223, yaxis-12, 30, 30);
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //buttonDelete.frame = CGRectMake(self.view.frame.size.width/2 + 100 + 223, yaxis-12, 30, 30);
            }
            [buttonDelete setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
            [buttonDelete addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            buttonDelete.tag = i;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [imageView addGestureRecognizer:singleTap];
            [imageView setUserInteractionEnabled:YES];
            
            if (imageLocal) {
                [imageView setImage:imageLocal];
            }
            yaxis = yaxis + heightForCell + 30;
            self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yaxis);
            
            [self.scrollView addSubview:imageView];
            [self.scrollView addSubview:buttonDelete];
            
        }
    } else {
        for (int i = 0; i < [[[User sharedUser] allImages] count]; i++) {
            UIImage *image = [[[User sharedUser] allImages] objectAtIndex:i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(43, yaxis, 240, 223)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //imageView.frame = CGRectMake(self.view.frame.size.width/2 + 100, yaxis, 240, 223);
            }
            //NSLog(@"%d %d %d %d", 43, yaxis, 240, 223);
            imageView.layer.cornerRadius = 5.0;
            imageView.layer.borderWidth = 2.0;
            imageView.clipsToBounds = YES;
            imageView.layer.borderColor = [[UIColor blackColor] CGColor];
            imageView.backgroundColor = [UIColor blackColor];
            imageView.tag = i;
            
            UIButton *buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonDelete.frame = CGRectMake(43+223, yaxis-12, 30, 30);
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //buttonDelete.frame = CGRectMake(self.view.frame.size.width/2 + 100 + 223, yaxis-12, 30, 30);
            }
            [buttonDelete setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
            [buttonDelete addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            buttonDelete.tag = i;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [imageView addGestureRecognizer:singleTap];
            [imageView setUserInteractionEnabled:YES];
            
            if (image) {
                [imageView setImage:image];
            }
            yaxis = yaxis + heightForCell + 30;
            self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yaxis);
            
            [self.scrollView addSubview:imageView];
            [self.scrollView addSubview:buttonDelete];
        }
    }
}

- (void) deleteImage:(UIButton *) sender {
    //NSLog(@"hkgfvjg %d", sender.tag);
    self.deleteTouchedIndex = sender.tag;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Are you sure about deleting this picture?" message:@""
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Ok", nil];
    [alert setTag:sender.tag];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {
        
    } else {
        if (self.productView) {
            Image *image = [self.imagesArray objectAtIndex:alertView.tag];
            [image deleteImageFromDevice:@""];
            [self.imagesArray removeObject:image];
            [Inspection sharedInspection].currentAudit.currentPictureCount = [self.imagesArray count];
        } else {
            UIImage *image = [[[User sharedUser] allImages] objectAtIndex:alertView.tag];
            [[[User sharedUser] allImages] removeObject:image];
            //[self.rawImagesArray removeObject:image];
        }
        for (UIView *subview in self.scrollView.subviews) {
            [subview removeFromSuperview];
        }
        //[self addContentsToScrollView];
        [self.tableView reloadData];
    }
}

- (void)imageTapped:(UIGestureRecognizer *)gestureRecognizer {
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
    int imageTappedNumber = [tapRecognizer.view tag];
    UIImage *imageLocal;
    Image *imageObjectForEdit;
    NSString *parentView = @"";
    if ([self.imagesArray count] > 0) {
        imageObjectForEdit = [self.imagesArray objectAtIndex:imageTappedNumber];
        parentView = kNibProductViewController;
    } else {
        imageLocal = [[[User sharedUser] allImages] objectAtIndex:imageTappedNumber];
        parentView = kNibContainerViewController;
    }
    ImageEditViewController *imageEditViewController = [[ImageEditViewController alloc] initWithNibName:kNibFileImageEditViewController bundle:nil];
    if (imageLocal) {
        imageEditViewController.imageForEdit = imageLocal;
    } else {
        imageEditViewController.imageObjectForEdit = imageObjectForEdit;
    }
    imageEditViewController.parentView = parentView;
    [self.navigationController pushViewController:imageEditViewController animated:YES];
}

@end
