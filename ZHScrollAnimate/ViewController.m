//
//  ViewController.m
//  ZHScrollAnimate
//
//  Created by zhusanbao on 2017/12/30.
//  Copyright © 2017年 zhusanbao. All rights reserved.
//

#import "ViewController.h"
#import "ZHSimpleAnimateView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet ZHSimpleAnimateView *simpleView;

@property (strong, nonatomic) ZHSimpleAnimateView *scrollView;
@property (strong, nonatomic) NSArray *names;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.names = @[@"人生若只如初见",@"何事秋风悲画扇",@"等闲变却故人心",@"却道故人心易变",@"骊山语罢清宵半",@"泪雨霖铃终不怨",@"何如薄幸锦衣郎",@"比翼连枝当日愿"];
    
    self.scrollView = [[ZHSimpleAnimateView alloc] initWithScrollType:kMSimpleAnimateTypeB2T];
//    self.scrollView = [[ZHSimpleAnimateView alloc] initWithScrollType:kMSimpleAnimateTypeCurlUp];
//    self.scrollView.autoAnimate     = YES;
    self.scrollView.timeInterval    = 4;
    //    self.scrollView.frame = CGRectMake(80, 80, 200, 30);
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    
    NSArray *HC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[scrollView(200)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"scrollView":self.scrollView}];
    NSArray *VC = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[scrollView(30)]" options:0 metrics:nil views:@{@"scrollView":self.scrollView}];
    
    [self.view addConstraints:HC];
    [self.view addConstraints:VC];
    
    __weak typeof(self)wkSelf = self;
    self.scrollView.viewForIndex = ^UIView *(NSInteger index){
        NSLog(@"%ld",index);
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor colorWithRed:1.0 green:arc4random()%125/255.0 blue:arc4random()%125/255.0 alpha:1];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = wkSelf.names[index%wkSelf.names.count];
        return label;
    };

    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)next {
    [self.scrollView nextWithAnimate:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
