//
//  ViewController.m
//  TestCoreML
//
//  Created by suwei on 2017/6/8.
//  Copyright © 2017年 CoreML. All rights reserved.
//

#import "ViewController.h"
#import <CoreML/CoreML.h>
#import "Resnet50.h"
#import <Vision/Vision.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *recognitionResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *confidenceResult;
@property (strong, nonatomic) UIImagePickerController *imagePickController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.selectedImageView.image = selectImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectImageAction:(UIButton *)sender {
    self.imagePickController = [[UIImagePickerController alloc] init];
    self.imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickController.delegate = self;
    self.imagePickController.allowsEditing = YES;
    [self presentViewController:self.imagePickController animated:YES completion:nil];
}
- (IBAction)startRecognitionAction:(UIButton *)sender {
    Resnet50 *resnetModel = [[Resnet50 alloc] init];
    UIImage *image = self.selectedImageView.image;
    VNCoreMLModel *vnCoreModel = [VNCoreMLModel modelForMLModel:resnetModel.model error:nil];
    
    VNCoreMLRequest *vnCoreMlRequest = [[VNCoreMLRequest alloc] initWithModel:vnCoreModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        CGFloat confidence = 0.0f;
        VNClassificationObservation *tempClassification = nil;
        for (VNClassificationObservation *classification in request.results) {
            if (classification.confidence > confidence) {
                confidence = classification.confidence;
                tempClassification = classification;
            }
        }
        
        self.recognitionResultLabel.text = [NSString stringWithFormat:@"识别结果:%@",tempClassification.identifier];
        self.confidenceResult.text = [NSString stringWithFormat:@"匹配率:%@",@(tempClassification.confidence)];
    }];
    
    VNImageRequestHandler *vnImageRequestHandler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:nil];
    
    NSError *error = nil;
    [vnImageRequestHandler performRequests:@[vnCoreMlRequest] error:&error];
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

@end
