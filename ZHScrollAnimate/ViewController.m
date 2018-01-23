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
//    self.scrollView.scrollEnable = YES;
//    self.scrollView = [[ZHSimpleAnimateView alloc] initWithScrollType:kMSimpleAnimateTypeCurlUp];
    self.scrollView.autoAnimate     = YES;
    self.scrollView.timeInterval    = 1;
    //    self.scrollView.frame = CGRectMake(80, 80, 200, 30);
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    self.scrollView.backgroudImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.scrollView.backgroudImageView.image = [UIImage imageNamed:@"1"];
    
    NSArray *HC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[scrollView(200)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"scrollView":self.scrollView}];
    NSArray *VC = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-180-[scrollView(60)]" options:0 metrics:nil views:@{@"scrollView":self.scrollView}];
    
    [self.view addConstraints:HC];
    [self.view addConstraints:VC];
    self.scrollView.numberOfRows = 10;
    __weak typeof(self)wkSelf = self;
    self.scrollView.viewForIndex = ^UIView *(NSInteger index){
        NSLog(@"%ld | showIndex : %ld",index,wkSelf.scrollView.showIndex);
        UILabel *label = [[UILabel alloc] init];
//        label.backgroundColor = [UIColor colorWithRed:(arc4random()%100+100)/255.0 green:0.3 blue:0.3 alpha:1];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@[%ld]",wkSelf.names[index%wkSelf.names.count],index];
        return label;
    };
    
//    self.scrollView.viewWillShow = ^(UIView *subView) {
//        NSLog(@"[Will Show : %@]",subView);
//    };
//    self.scrollView.viewDidShowAtIndex = ^(UIView *subView, NSInteger index) {
//        NSLog(@"[Did Show : %@ | Index %ld]",subView,index);
//    };
//    self.scrollView.viewForIndex = ^UIView *(NSInteger index){
//        NSLog(@"%ld",index);
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld",(index%3)]]];
//        return imgView;
//    };

    // Do any additional setup after loading the view, typically from a nib.
}


//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.scrollView scrollToIndex:arc4random()%10 animate:YES];
//}
- (IBAction)randomScroll:(id)sender {
    [self.scrollView scrollToIndex:arc4random()%10 animate:YES];
}

- (IBAction)next {
//    __weak typeof(self)wkSelf = self;
    [self.scrollView nextWithAnimate:YES complete:^(BOOL finished) {
//        NSLog(@"complete finished %d",finished);
//        NSLog(@"%@",wkSelf.scrollView.showView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
