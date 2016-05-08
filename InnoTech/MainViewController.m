//
//  MainViewController.m
//  InnoTech
//
//  Created by Vladyslav Gusakov on 5/3/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import "MainViewController.h"
#import "MainTableViewCell.h"
#import "SWRevealViewController.h"
#import "Product.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+AFNetworking.h"
#import "DetailViewController.h"

#define LC_URL              "https://cdn.livechatinc.com/app/mobile/urls.json"
#define LC_LICENSE          "7477711"
#define LC_CHAT_GROUP       "0"


@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) NSString *link;

@property (nonatomic, strong) NSString *chatURL;

@end

@implementation MainViewController {
    NSMutableArray <Product *> *menuItems;
}
static NSString *pname = @"name";
static NSString *pdescr = @"descr";
static NSString *pimage = @"image_url";
static NSString *purl = @"url";
static NSString *pcat = @"categories";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 160;
    
    // Initialize Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    // Configure Refresh Control
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    // Configure View Controller
    [self setRefreshControl:refreshControl];
    
    menuItems = [[NSMutableArray alloc] init];
    
//    Product *product4 = [[Product alloc] initWithName:@"3Doodler" description:@"The World's First 3D Printing Pen" image: [UIImage imageNamed:@"doodler.png"]];

    [self requestWithURL:@"https://innotech.firebaseio.com/array/products.json" requestType:@"GET"];
    
//    UIBarButtonItem *chatButton = [[UIBarButtonItem alloc]
//                                   initWithTitle:@"HELP"
//                                   style:UIBarButtonItemStyleDone
//                                   target:self
//                                   action:@selector(startChat:)];
//    [self.navigationItem setRightBarButtonItem:chatButton];
    
    
    
    [self requestUrl];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view setAlpha:0];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view setAlpha:1];
}

- (void)refresh:(id)sender
{
    NSLog(@"Refreshing");
    
    [self requestWithURL:@"https://innotech.firebaseio.com/array/products.json" requestType:@"GET"];

    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)requestWithURL:(NSString *)url requestType:(NSString *)reqType
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:reqType URLString:[NSString stringWithFormat:@"%@",url] parameters:nil error:nil];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
//            NSLog(@"Reply JSON: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self handleResponse: (NSDictionary *) responseObject];
            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

-(void) handleResponse: (NSDictionary *) responseDict {
    
    if ([[responseDict objectForKey:@"product"] count] == menuItems.count) {
        return;
    }
    
    for (id object in [responseDict objectForKey:@"product"]) {
        
        Product *product = [[Product alloc] initWithName:[object valueForKey:pname] description:[object valueForKey:pdescr] image:[object valueForKey:pimage]];
        product.urlString = [object valueForKey:purl];
        [menuItems addObject:product];
        
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuItems.count;
}


- (MainTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.backgroundImageView setImageWithURL:[NSURL URLWithString:menuItems[indexPath.row].image]];
    cell.title.text = [menuItems[indexPath.row].name uppercaseString];
    cell.descr.text = menuItems[indexPath.row].shortDescription;
    cell.link.text = menuItems[indexPath.row].urlString;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue destinationViewController] isKindOfClass:[DetailViewController class]]) {
        MainTableViewCell *cellSelected = ((MainTableViewCell *) sender);
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cellSelected];
        ((DetailViewController *) [segue destinationViewController]).link = menuItems[indexPath.row].urlString;
    }
}

#pragma mark Helper functions

- (NSString *)prepareUrl:(NSString *)url
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"https://%@", url];
    
    [string replaceOccurrencesOfString:@"{%license%}"
                            withString:@LC_LICENSE
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    
    [string replaceOccurrencesOfString:@"{%group%}"
                            withString:@LC_CHAT_GROUP
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    
    return string;
}

#pragma mark Tasks

- (void)requestUrl
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@LC_URL];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSError *jsonError;
                    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&jsonError];
                    
                    if ([JSON isKindOfClass:[NSDictionary class]] && [JSON valueForKey:@"chat_url"] != nil) {
                        self.chatURL = [self prepareUrl:JSON[@"chat_url"]];
                    } else if (jsonError) {
                        NSLog(@"%@", jsonError);
                    }
                } else {
                    NSLog(@"%@", error);
                }
            }] resume];
}

#pragma mark Actions

- (void)startChat:(UIButton*)button {
    
//    if (!self.chatViewController) {
//        self.chatViewController = [[LCCChatViewController alloc] initWithChatUrl:self.chatURL];
//    }
//    
//    [self.navigationController pushViewController:self.chatViewController animated:YES];
}
@end
