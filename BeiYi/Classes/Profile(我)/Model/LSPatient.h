//
//  LSPatient.h
//  BeiYi
//
//  Created by LiuShuang on 15/5/26.
//  Copyright (c) 2015年 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSPatient : NSObject

/**
 *  就诊人模型
 */

/** 就诊人详细地址 */
@property (nonatomic, copy) NSString *address;
/** 就诊人身份证号码 */
@property (nonatomic, copy) NSString *id_card;
/** 就诊人联系电话 */
@property (nonatomic, copy) NSString *mobile;
/** 就诊人id */
@property (nonatomic, copy) NSString *patient_id;
/** 就诊人年龄 */
@property (nonatomic, copy) NSString *age;
/** 就诊人性别 1-男 2-女 */
@property (nonatomic, copy) NSString *sex;
/** 就诊人姓名 */
@property (nonatomic, copy) NSString *name;

@end
