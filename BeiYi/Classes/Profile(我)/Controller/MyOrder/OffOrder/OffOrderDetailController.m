//
//  OffOrderDetailController.m
//  BeiYi
//
//  Created by Joe on 15/6/24.
//  Copyright (c) 2015年 Joe. All rights reserved.
//

#import "OffOrderDetailController.h"
#import "LSSelectPayModeController.h"
#import "HosInfoCell.h"
#import "PayCell.h"
#import "AttendanceTimeCell.h"
#import "OrderNumCell.h"
#import "AttendanceInfoCell.h"
#import "ApplyTheOrderController.h"
#import "UIButton+WebCache.h"
#import "CommentController.h"
#import "Common.h"

@interface OffOrderDetailController ()<AttendanceInfoCellDelegate>
/** 就诊信息 cell 的高度 */
@property (nonatomic, assign) CGFloat *AttendInfoHeight;
@property (nonatomic, strong) UIButton *imageBgView;

@end

@implementation OffOrderDetailController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ZZLog(@"----self.orderInfo---%@",self.orderInfos);
    
    // 1.基本设置
    self.view.backgroundColor = ZZColor(245, 245, 245, 1);
    self.title = @"订单详情";
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, ZZMarins, 0);
    
    // 2.设置tableView的FootView
    switch ([self.orderInfos[@"order_status"] intValue]) {
        case 1:// 待付款
            self.tableView.tableFooterView = [self footViewCreatedWithBtnTitle:@"提交保证金"];
            break;
            
        case 2:// 已付款
            self.tableView.tableFooterView = [self footViewCreatedWithBtnTitle:@"撤销订单"];
            break;
            
        case 3:// 已被抢(未付款)
            self.tableView.tableFooterView = [self footViewCreatedWithBtnTitle:@"申请退单"];
            break;
            
        case 4:// 已被抢(已付款)
            self.tableView.tableFooterView = [self footViewCreatedWithBtnTitle:@"申请退单"];
            break;
            
        case 5:// 申请退单中
            self.tableView.tableFooterView = [[UIView alloc] init];
            break;
            
        case 6:// 退单被拒绝
//             只允许申请一次退单，被拒绝之后，只能——>等待对方完成订单
            self.tableView.tableFooterView = [[UIView alloc] init];
            break;

        case 7:// 凭证已提交
            // 对方已经提交凭证，选择确认/取消凭证
            self.tableView.tableFooterView = [self footViewDoubleBtn];
            break;
            
        case 8:// 凭证被拒绝
            self.tableView.tableFooterView = [[UIView alloc] init];
            break;
            
        case 9:// 交易完成
            self.tableView.tableFooterView = [[UIView alloc] init];
            break;
            
        case 10:// 交易关闭
            self.tableView.tableFooterView = [[UIView alloc] init];
            break;
        
        case 11:// 待评价
            self.tableView.tableFooterView = [self footViewCreatedWithBtnTitle:@"评价"];
            break;
    }
}

#pragma mark 设置医院信息
- (void)setHospitalInfo {
    // 1.背景View
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT/4)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    CGFloat marinX = ZZMarins;
    CGFloat marinY = ZZMarins/2;
    CGFloat bgViewY = bgView.frame.size.height;
    CGFloat labelH = bgViewY/3 - 2*marinY;

    // 2.医院信息
    [ZZUITool labelWithframe:CGRectMake(marinX, marinY, SCREEN_WIDTH/4, labelH) Text:@"医  院" textColor:ZZColor(51, 51, 51, 1) fontSize:17 superView:bgView];
    
    UILabel *hosName = [ZZUITool labelWithframe:CGRectMake(3*SCREEN_WIDTH/4-ZZMarins, marinY, SCREEN_WIDTH/4, labelH) Text:_orderInfos[@"hospital_name"] textColor:ZZBaseColor fontSize:17 superView:bgView];
    hosName.textAlignment = NSTextAlignmentRight;
    
    // 3.科室信息
    [ZZUITool labelWithframe:CGRectMake(marinX, bgViewY/3+marinY, SCREEN_WIDTH/4, labelH) Text:@"科  室" textColor:ZZColor(51, 51, 51, 1) fontSize:17 superView:bgView];
    
    UILabel *departName = [ZZUITool labelWithframe:CGRectMake(3*SCREEN_WIDTH/4-ZZMarins, bgViewY/3+marinY, SCREEN_WIDTH/4, labelH) Text:_orderInfos[@"department_name"] textColor:ZZBaseColor fontSize:17 superView:bgView];
    departName.textAlignment = NSTextAlignmentRight;
    
    // 4.医生信息
    [ZZUITool labelWithframe:CGRectMake(marinX, 2*bgViewY/3+marinY, SCREEN_WIDTH/4, labelH) Text:@"医  生" textColor:ZZColor(51, 51, 51, 1) fontSize:17 superView:bgView];
    
    NSString *doctor_Name;
    if (![_orderInfos[@"doctor_name"] isEqual:[NSNull null]]) {
        doctor_Name = _orderInfos[@"doctor_name"];
    
    }else {
        doctor_Name = @"";
    }
    
    UILabel *doctorName = [ZZUITool labelWithframe:CGRectMake(3*SCREEN_WIDTH/4-ZZMarins, 2*bgViewY/3+marinY, SCREEN_WIDTH/4, labelH) Text:doctor_Name textColor:ZZBaseColor fontSize:17 superView:bgView];
    doctorName.textAlignment = NSTextAlignmentRight;
    
    // 5.分割线
    [ZZUITool linehorizontalWithPosition:CGPointMake(80, bgViewY/3) width:SCREEN_WIDTH-80-marinX backGroundColor:[UIColor lightGrayColor] superView:bgView];
    
    [ZZUITool linehorizontalWithPosition:CGPointMake(80, 2*bgViewY/3) width:SCREEN_WIDTH-80-marinX backGroundColor:[UIColor lightGrayColor] superView:bgView];
}

#pragma mark - 返回tableView的footView
- (UIView *)footViewCreatedWithBtnTitle:(NSString *)title {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ZZBtnHeight)];
    
    CGFloat x = ZZMarins;
    CGFloat w = (SCREEN_WIDTH - 2*ZZMarins);
    
    // 按钮
    UIButton *btn = [ZZUITool buttonWithframe:CGRectMake(x, 20, w, ZZBtnHeight) title:title titleColor:nil backgroundColor:ZZButtonColor target:self action:@selector(payBtnClicked) superView:footView];
    btn.layer.cornerRadius = 3.0f;

    return footView;
}

#pragma mark - 返回双按钮的footView
- (UIView *)footViewDoubleBtn {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), SCREEN_WIDTH, 60)];
    
    CGFloat x = ZZMarins;
    CGFloat btnW = ((SCREEN_WIDTH - 2*ZZMarins)-ZZMarins)/2;
    
    // 确认凭证-按钮
    UIButton *btn1 = [ZZUITool buttonWithframe:CGRectMake(x, 20, btnW, ZZBtnHeight) title:@"确认凭证" titleColor:nil backgroundColor:ZZButtonColor target:self action:@selector(confirmBtnClicked) superView:footView];
    btn1.layer.cornerRadius = 3.0f;
    
    // 拒绝凭证-按钮
    UIButton *btn2 = [ZZUITool buttonWithframe:CGRectMake(2*x +btnW, 20, btnW, ZZBtnHeight) title:@"拒绝凭证" titleColor:nil backgroundColor:ZZButtonColor target:self action:@selector(refuseClicked) superView:footView];
    btn2.layer.cornerRadius = 3.0f;

    return footView;
}

#pragma mark - 监听 “支付按钮” 点击
- (void)payBtnClicked {
    ZZLog(@"~-----#$!$#^$!#$#^!#-----~");
    
    switch ([self.orderInfos[@"order_status"] intValue]) {
        case 1:// 待付款
            [self payForOrder]; // 支付保证金
            break;
            
        case 2:// 已付款
            [self cancelOrder]; // 撤单——>交易关闭
            break;
            
        case 3:// 已被抢(未付款)
            [self applyCancelTheOrder]; // 申请退单
            break;
            
        case 4:// 已被抢(已付款)
            [self applyCancelTheOrder]; // 申请退单
            break;
            
        case 5:// 申请退单中
            // （按钮已隐藏）
            break;
            
        case 6:// 拒绝被退单
            // （按钮已隐藏）
             break;

        case 7:// 凭证已提交
            // （按钮已隐藏）(已经单独处理)
            break;
            
        case 8:// 拒绝凭证
            // （按钮已隐藏）
            break;
            
        case 9:// 交易完成
            // （按钮已隐藏）
            break;
            
        case 10:// 交易关闭
            //(已经单独处理)
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 支付保证金
- (void)payForOrder {
    // 1.跳转到选择支付界面
    LSSelectPayModeController *selectPayModeVc = [[LSSelectPayModeController alloc] init];
    
    // 2.传值：保证金金额、订单编号
    selectPayModeVc.price = [NSString stringWithFormat:@"￥%.2f",[self.orderInfos[@"price"] floatValue]];
    selectPayModeVc.payType = @"2"; // 付款类型2-发布订单 4-抢单
    selectPayModeVc.orderCode = self.orderInfos[@"order_code"];
    [self.navigationController pushViewController:selectPayModeVc animated:YES];
}

#pragma mark - 撤单
- (void)cancelOrder {
    [MBProgressHUD showMessage:@"请稍后..."];
    
    // 1.准备参数
    NSString *urlStr = [NSString stringWithFormat:@"%@/uc/order/cancel_order",BASEURL];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:myAccount.token forKey:@"token"];// 登录token
    [params setObject:self.orderInfos[@"order_code"] forKey:@"order_code"];
    
    // 2.发送post请求
    [ZZHTTPTool post:urlStr params:params success:^(NSDictionary *responseObj) {
        ZZLog(@"---撤单---%@",responseObj);
        [MBProgressHUD hideHUD];
        
        if ([responseObj[@"code"] isEqual:@"0000"]) {// 操作成功!
            // 返回我的订单界面
            [self.navigationController popViewControllerAnimated:YES];
        }else {// 操作失败
            [MBProgressHUD showError:responseObj[@"message"]];
        }
        
    } failure:^(NSError *error) {
        ZZLog(@"---撤单---%@",error);
        [MBProgressHUD hideHUD];
        
    }];
}

#pragma mark - 申请退单
- (void)applyCancelTheOrder {
    // 点击申请退单按钮，跳转进入新 申请退单 界面
    ApplyTheOrderController *applyVc = [[ApplyTheOrderController alloc] init];
    applyVc.orderCode = self.orderInfos[@"order_code"];
    [self.navigationController pushViewController:applyVc animated:YES];
}

#pragma mark - 监听 “确认凭证” 按钮
- (void)confirmBtnClicked {
    // 点击同意/不同意 按钮连接网络请求(tag = 1-同意 0-不同意)
    [self confirmHttploadWithTag:1];
}

#pragma mark - 监听 “拒绝凭证” 按钮
- (void)refuseClicked {
    // 点击同意/不同意 按钮连接网络请求(tag = 1-同意 0-不同意)
    [self confirmHttploadWithTag:0];
}

#pragma mark - 点击确认/拒绝凭证 按钮连接网络请求
// tag = 1-同意 0-不同意
- (void)confirmHttploadWithTag:(int)tag {
    // 1.准备参数
    NSString *urlStr = [NSString stringWithFormat:@"%@/uc/order/publish_confirm",BASEURL]; // 确认凭证
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:myAccount.token forKey:@"token"];// 登录token
    [params setObject:self.orderInfos[@"order_code"] forKey:@"order_code"];// 订单编号
    
    // 是否通过1-是 0-否
    [params setObject:[NSString stringWithFormat:@"%d",tag] forKey:@"result_flag"];
    
    __weak typeof(self) weakSelf = self;
    
    // 2.发送post请求
    [ZZHTTPTool post:urlStr params:params success:^(NSDictionary *responseObj) {
        
        // 2.1隐藏遮盖
        [MBProgressHUD hideHUD];
        
        // 2.2获取操作是否成功
        NSDictionary *resultDict = responseObj[@"result"];
        ZZLog(@"---点击确认/拒绝凭证 按钮---%@",resultDict);
        
        if ([responseObj[@"code"] isEqual:@"0000"]) {// 操作成功
            [MBProgressHUD showSuccess:responseObj[@"message"]];
            
            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
              
            }
            
        }else {// 操作失败
            [MBProgressHUD showError:responseObj[@"message"]];
            
        }
        
    } failure:^(NSError *error) {
        ZZLog(@"抢单---%@",error);
        
        // 隐藏遮盖
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"发生错误，请重试"];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else {
        int stateValue = [self.orderInfos[@"order_status"] intValue];
        if (stateValue == 7 || stateValue == 9) {// 7——>对方已提交凭证，可以看到对方凭证；9——>交易完成，可以看到完成信息
            return 4;
            
        }else {
            return 3;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {// 第一组三行分别显示医院，科室，医生
        HosInfoCell *cell = [HosInfoCell cellWithTableView:tableView];
        
        if (indexPath.row == 0) {
            cell.lblName.text = @"医 院";
            cell.lblDetailName.text = _orderInfos[@"hospital_name"];
            return cell;
            
        } else if (indexPath.row == 1) {
            cell.lblName.text = @"科 室";
            cell.lblDetailName.text = _orderInfos[@"department_name"];
            return cell;
            
        }else {
            cell.lblName.text = @"医  生";
            if (![_orderInfos[@"doctor_name"] isEqual:[NSNull null]]){
                cell.lblDetailName.text = _orderInfos[@"doctor_name"];
            }
            return cell;
        }
    }else {// 第二组cell
        
        if (indexPath.row == 0) {// 就诊人信息
            PayCell *cell = [PayCell cellWithTableView:tableView];
            cell.lbl2Detail.text = _orderInfos[@"human"][@"name"];
            cell.lbl3.text = [NSString stringWithFormat:@"身份证号: %@",_orderInfos[@"human"][@"id_card"]];
            cell.lbl4.text = [NSString stringWithFormat:@"手机号码: %@",_orderInfos[@"human"][@"mobile"]];
            
            if ([_orderInfos[@"human"][@"sex"] isEqual:@1]) {
                cell.lbl5.text = @"性别：男";
            }else {
                cell.lbl5.text = @"性别：女";
            }
            
            return cell;
            
        }
        else if (indexPath.row == 1) {// 就诊时间
            AttendanceTimeCell *cell = [AttendanceTimeCell cellWithTableView:tableView];
            
            cell.lblBeginTime.text = _orderInfos[@"start_time"];
            cell.lblEndTime.text = _orderInfos[@"end_time"];
            
            if ([_orderInfos[@"order_status"] intValue] == 6) {// 退单被拒
                cell.lblTip.hidden = NO;
                cell.lblTip.text = @"申请退单中";

                cell.lblType.hidden = NO;
                cell.lblType.text = [NSString stringWithFormat:@"退单类型：您申请的%@元退单被拒绝",_orderInfos[@"price"]];
            }
            
            return cell;
            
        }
        else if (indexPath.row == 2) {// 当状态值为7或者9时，显示的就诊信息，其余情况下显示订单号和价格
            
            // 状态值
            int state = [_orderInfos[@"order_status"] intValue];
            
            if (state == 7|| state == 8|| state == 9) {// 显示就诊信息

                AttendanceInfoCell *cell = [AttendanceInfoCell cellWithTableView:tableView];
                cell.delegate = self;
                
                // 文字说明
                if (![_orderInfos[@"over_over"][@"memo"] isEqual:[NSNull null]]) {// 如果文字说明返回不为null
                    cell.lblWord.hidden = NO;
                    cell.lblWord.text = [NSString stringWithFormat:@"文字说明：%@",_orderInfos[@"over_over"][@"memo"]];
                }
                
                // 取号时间
                cell.lblTime.text = _orderInfos[@"over_over"][@"take_time"];
                
                if (![_orderInfos[@"over_over"][@"images"] isEqual:[NSNull null]]) {// 如果 图片数组 返回不为null
                    cell.lblIconTip.hidden = NO;
                    cell.icon.hidden = NO;
                    NSString *urlStr = [_orderInfos[@"over_over"][@"images"] lastObject];
                    [cell.icon sd_setImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal placeholderImage:nil];
                }

                return cell;
                
            }else {// 显示订单号
                OrderNumCell *cell = [OrderNumCell cellWithTableView:tableView];
                cell.lblOrderNum.text = [NSString stringWithFormat:@"订单号：%@",self.orderInfos[@"order_code"]];
                cell.lblPrice.text = @"价格￥";
                cell.lblPriceDetail.text = [NSString stringWithFormat:@"%.2f",[self.orderInfos[@"price"] floatValue]];
                
                return cell;
            }

        }
        else {// 当状态值为7或者9时，才显示该行
            OrderNumCell *cell = [OrderNumCell cellWithTableView:tableView];
            cell.lblOrderNum.text = [NSString stringWithFormat:@"订单号：%@",self.orderInfos[@"order_code"]];
            cell.lblPrice.text = @"价格￥";
            cell.lblPriceDetail.text = [NSString stringWithFormat:@"%.2f",[self.orderInfos[@"price"] floatValue]];
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
        
    }else {
        if (indexPath.row == 0) {// 就诊人信息
            return 116;
            
        }else if (indexPath.row == 1) {// 就诊时间
            if ([_orderInfos[@"order_status"] intValue] == 6) {//订单被拒绝时，需要显示拒单提示
                return 120;
                
            }else {
                return 66;
            }
            
        }else if (indexPath.row == 2){// 该行cell，当状态值为7或者9时，显示的就诊信息，其余情况下显示订单号和价格
            
            int state = [_orderInfos[@"order_status"] intValue];
            if (state == 7|| state == 8|| state == 9) {// 显示就诊信息
//                return 150;// 动态返回
                AttendanceInfoCell *cell =  (AttendanceInfoCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];

                if ([_orderInfos[@"over_over"][@"images"] isEqual:[NSNull null]]) {// 没有图片凭证
                    
                    CGRect rect = cell.frame;

                    if ([_orderInfos[@"over_over"][@"memo"] isEqual:[NSNull null]]) {// 没有图片凭证，没有文字描述
                        
                        rect.size.height = 66;
                        cell.frame = rect;
                        
                    }else {// 没有图片凭证，有文字描述
                        CGSize lblWordSize = CGSizeMake(SCREEN_WIDTH - 15*2, 10000);// 高度自适应
                        CGSize lblWordSizeNew = [_orderInfos[@"over_over"][@"memo"] boundingRectWithSize:lblWordSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.5]} context:nil].size;
                        
                        rect.size.height = 66 + lblWordSizeNew.height;
                        cell.frame = rect;
                    }
                    
                }else {// 有图片凭证
                    
                    CGRect rect = cell.frame;
                    
                    if ([_orderInfos[@"over_over"][@"memo"] isEqual:[NSNull null]]) {// 有图片凭证，没有文字描述
                        
                        rect.size.height = 110;
                        cell.frame = rect;
                        
                    }else {// 有图片凭证，有文字描述
                        CGSize lblWordSize = CGSizeMake(SCREEN_WIDTH - 15*2, 10000);// 高度自适应
                        CGSize lblWordSizeNew = [_orderInfos[@"over_over"][@"memo"] boundingRectWithSize:lblWordSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.5]} context:nil].size;
                        rect.size.height = 110 + lblWordSizeNew.height;
                        cell.frame = rect;
                    }

                }
                
                ZZLog(@"----cell.frame.size.height----%f",cell.frame.size.height);
                
                return cell.frame.size.height;
                
            }else {// 显示订单号
                return 66;
            }
            
        }else {// 当状态值为7或者9时，才显示该行
            return 66;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.001;
    }else {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 20;
        
    }else {
        return 0.01;
    }
}

#pragma mark - AttendanceInfoCellDelegate
- (void)attendanceInfoCellIconBtnClicked:(AttendanceInfoCell *)cell {
    
    UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn.frame = self.tableView.frame;
    imgBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [imgBtn setImage:cell.icon.imageView.image forState:UIControlStateNormal];
    imgBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imgBtn addTarget:self action:@selector(clearImage) forControlEvents:UIControlEventTouchUpInside];
    imgBtn.adjustsImageWhenHighlighted = NO;
    [self.tableView addSubview:imgBtn];

    self.imageBgView = imgBtn;
    
}

- (void)clearImage {
    [self.imageBgView removeFromSuperview];
    self.imageBgView = nil;
}

@end
