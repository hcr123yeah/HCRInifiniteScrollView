# HCRInifiniteScrollView
this is very cool infinite scrolling view
```objc

 (void)viewDidLoad {
    [super viewDidLoad];
    
    XMGInfiniteScrollView *scrollView = [[XMGInfiniteScrollView alloc] init];
    scrollView.images = @[
                          [UIImage imageNamed:@"img_00"],
                          [UIImage imageNamed:@"img_01"],
                          [NSURL URLWithString:@"http://tupian.enterdesk.com/2013/mxy/12/10/15/3.jpg"],
                          [UIImage imageNamed:@"img_03"],
                          [NSURL URLWithString:@"http://pic4.nipic.com/20091215/2396136_140959028451_2.jpg"]
                          ];
//    scrollView.placeholderImage = [UIImage imageNamed:@"imglogo-r"];
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

```
