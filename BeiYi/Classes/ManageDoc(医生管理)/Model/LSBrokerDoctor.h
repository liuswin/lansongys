//
//  LSBrokerDoctor.h
//  BeiYi
//
//  Created by Joe on 15/9/14.
//  Copyright (c) 2015年 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSBrokerDoctor : NSObject

/** 头像 */
@property (nonatomic, strong) NSURL *avator;

/** 医生评分 */
@property (nonatomic, copy) NSString *avg_score;

/** 医院简称 */
@property (nonatomic, copy) NSString *hospital_name;
@property (nonatomic, copy) NSString *short_name;

/** 医生id */
@property (nonatomic, copy) NSString *doctor_id;

/** 医生等级 */
@property (nonatomic, copy) NSString *level;

/** 医生擅长 */
@property (nonatomic, copy) NSString *good_at;

/** 科室id */
@property (nonatomic, copy) NSString *department_id;

/** 就诊人数量 */
@property (nonatomic, copy) NSString *visit_count;

/** 科室名称 */
@property (nonatomic, copy) NSString *dept_name;

/** 医院id */
@property (nonatomic, copy) NSString *hospital_id;

/** 医生姓名 */
@property (nonatomic, copy) NSString *name;

@end
