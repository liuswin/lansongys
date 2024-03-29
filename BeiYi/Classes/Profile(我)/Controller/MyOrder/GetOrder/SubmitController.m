//
//  SubmitController.m
//  BeiYi
//
//  Created by Joe on 15/6/26.
//  Copyright (c) 2015年 Joe. All rights reserved.
//

#import "SubmitController.h"
#import "Common.h"
#import "ZZTextView.h"
#import "OrderTimeListController.h"

@interface SubmitController ()<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,OrderTimeListVcDelegate>

/** UITextField 凭证描述 */
@property (nonatomic, strong) ZZTextView *txFieldDesc;
/** UITextField 取号时间 */
@property (nonatomic, strong) UITextField *txFieldTime;
/** UIButton 上传图片按钮 */
@property (nonatomic, strong) UIButton *btnUploadImg;
/** NSString 经过base64编码的图片 */
@property (nonatomic, strong) NSString *base64StrForImg;
/** int 取号具体时间1-上午 2-下午 */
@property (nonatomic, assign) int timeSelected;

@end

@implementation SubmitController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.基本设置
    self.view.backgroundColor = ZZColor(245, 245, 245, 1);
    self.title = @"提交凭证";
    
    // 2.界面布局
    [self setUpUI];
    
    // 3.UITextView从顶部开始显示内容
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

// 可以触摸使self.txFieldDesc隐藏？？？
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txFieldDesc resignFirstResponder];
    
}

- (void)setUpUI {
    // 1.UITextField 凭证描述
    self.txFieldDesc = [[ZZTextView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT/4)];
    self.txFieldDesc.backgroundColor = [UIColor whiteColor];
    self.txFieldDesc.placeholder = @"描述您的凭证...";
    self.txFieldDesc.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.txFieldDesc];
    self.txFieldDesc.delegate = self;
    
    // 分割线1的Y值
    CGFloat line1Y = CGRectGetMaxY(_txFieldDesc.frame)+ZZMarins;
    
    // 2.UIView 取号时间背景
    UIView *backView = [ZZUITool viewWithframe:CGRectMake(0, line1Y, SCREEN_WIDTH, 50) backGroundColor:[UIColor whiteColor] superView:self.view];
    
    // 3.UILabel:取号时间提醒
    UILabel *lblTip = [ZZUITool labelWithframe:CGRectMake(10, 10, SCREEN_WIDTH/4, 30) Text:@"取号时间：" textColor:[UIColor darkGrayColor] fontSize:15 superView:backView];
    
    // 4.UILabel:选择取号时间
    CGFloat txFieldTimeX = CGRectGetMaxX(lblTip.frame);
    self.txFieldTime = [ZZUITool textFieldWithframe:CGRectMake(txFieldTimeX, 10, SCREEN_WIDTH-txFieldTimeX-40, 30) text:nil fontSize:15 placeholder:@"请选择取号时间" backgroundColor:nil superView:backView];
    self.txFieldTime.textAlignment = NSTextAlignmentRight;
    self.txFieldTime.enabled = NO;
    
    // 6.箭头
    [ZZUITool imageViewWithframe:CGRectMake(SCREEN_WIDTH-30, 12.5, 12, 25) imageName:@"profile14" highlightImageName:nil superView:backView];
    
    // 8.透明大按钮？？怎么替代
    [ZZUITool buttonWithframe:backView.bounds title:nil titleColor:nil backgroundColor:nil target:self action:@selector(selectTime) superView:backView];
    
    // 9.凭证图片按钮
    self.btnUploadImg = [ZZUITool buttonWithframe:CGRectMake(10, CGRectGetMaxY(backView.frame) +ZZMarins, 80, 80) title:nil titleColor:nil backgroundColor:nil target:self action:@selector(addImage) superView:self.view];
    self.btnUploadImg.adjustsImageWhenHighlighted = NO;
    [self.btnUploadImg setImage:[UIImage imageNamed:@"submit"] forState:UIControlStateNormal];
    
    // 10.设置导航栏右侧按钮
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave.frame = CGRectMake(270, 0, 60, 40);
    [btnSave setTitle:@"提交" forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnSave addTarget:self action:@selector(gotoSubmit) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    
}

#pragma mark - 监听右侧提交按钮点击
- (void)gotoSubmit {
    [self.view endEditing:YES];

    if (self.txFieldTime.text.length == 0) {
        [MBProgressHUD showError:@"请选择取号时间" toView:self.view];
        return;
    }
    
    // 1.准备参数
    NSString *urlStr = [NSString stringWithFormat:@"%@/uc/order/offer_complete",BASEURL]; // 提交订单凭证
    
    NSMutableDictionary *params  = [NSMutableDictionary dictionary];
    [params setObject:myAccount.token forKey:@"token"];
    // 订单编号
    [params setObject:self.orderCode forKey:@"order_code"];
    // 凭证描述
    [params setObject:self.txFieldDesc.text forKey:@"memo"];
    // 取号日期
    [params setObject:self.txFieldTime.text forKey:@"take_time"];
    // 取号具体时间1-上午 2-下午
    [params setObject:[NSString stringWithFormat:@"%d",self.timeSelected] forKey:@"exact_type"];
    
    __weak typeof(self) weakSelf = self;
    
    // 2.发送网络请求
    [ZZHTTPTool post:urlStr params:params success:^(NSDictionary *responseObj) {
        ZZLog(@"~~~%@~~~",responseObj);
        
        if ([responseObj[@"code"] isEqualToString:@"0000"]) {// 提交成功
            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                
            }
            
            [MBProgressHUD showSuccess:responseObj[@"message"] toView:weakSelf.view];
            
        }else {
            [MBProgressHUD showError:responseObj[@"message"] toView:weakSelf.view];
        }

        
    } failure:^(NSError *error) {
        ZZLog(@"~~~%@~~~",error);
        
    }];
}


#pragma mark - 监听 选择取号时间按钮 点击
- (void)selectTime {
    [self.view endEditing:YES];
    ZZLog(@"-----请选择取号时间-----");

    // 跳转到添加凭证界面，选中时间返回
    OrderTimeListController *orderTimeVc = [[OrderTimeListController alloc] init];
    orderTimeVc.orderCode = self.orderCode;
    orderTimeVc.delegate = self;
    [self.navigationController pushViewController:orderTimeVc animated:YES];
}

#pragma mark - OrderTimeListVcDelegate
- (void)OrderTimeListPassTime:(NSString *)time timeSelected:(int)timeSelected {
    // 选择取号时间
    self.txFieldTime.text = time;
    // 选择具体时间1-上午 2-下午
    self.timeSelected = timeSelected;
}

#pragma mark - 监听 添加凭证图片按钮 点击
- (void)addImage {
    [self.view endEditing:YES];

    // 调用相机，选择图片
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选择", nil];
    [sheet showInView:[self.view window]];
}

#pragma mark - UITextViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {// 调用相册
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        
        [self presentViewController:ipc animated:YES completion:nil];
        
    }else if (buttonIndex == 0){// 调用相机
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.delegate = self;
        
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 1.退出相机
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 2.将凭证图片base64编码
    NSData *imgData = UIImageJPEGRepresentation(info[@"UIImagePickerControllerOriginalImage"], 0.5);
    self.base64StrForImg = [imgData base64Encoding];
    
    // 3.上传凭证图片
    [self updateImageWithImage:info[UIImagePickerControllerOriginalImage]];
    
}

#pragma mark - 上传凭证图片
- (void)updateImageWithImage:(UIImage *)image {
    // 1.准备参数
    NSString *urlStr = [NSString stringWithFormat:@"%@/uc/order/upload_certify",BASEURL]; // 提交订单凭证
    
    NSMutableDictionary *params  = [NSMutableDictionary dictionary];
    
    [params setObject:myAccount.token forKey:@"token"];
    // 图片数据，base64加密后的字符串
    [params setObject:self.base64StrForImg forKey:@"image_str"];
    // 图片后缀名
    [params setObject:@".jpg" forKey:@"suffix"];
    // 订单编号
    [params setObject:self.orderCode forKey:@"order_code"];
    
    __weak typeof(self) weakSelf = self;
    
    // 2.发送网络请求
    [ZZHTTPTool post:urlStr params:params success:^(NSDictionary *responseObj) {
        ZZLog(@"~~~%@~~~",responseObj);
        
        if ([responseObj[@"code"] isEqualToString:@"0000"]) {// 上传成功
            [MBProgressHUD showSuccess:@"凭证上传成功" toView:weakSelf.view];

            // 3.设置凭证图片
            [weakSelf.btnUploadImg setImage:image forState:UIControlStateNormal];
            
        }else {// 凭证上传失败
            [MBProgressHUD showError:@"凭证上传失败" toView:weakSelf.view];
        }
        
    } failure:^(NSError *error) {
        ZZLog(@"~~~%@~~~",error);
        
    }];
}

@end
