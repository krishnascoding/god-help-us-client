//
//  SettingsViewController.m
//  InnoTech
//
//  Created by Vladyslav Gusakov on 5/2/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import "SettingsViewController.h"
#import "CustomCell.h"
#import "ChatMessage.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)closeSettings:(id)sender;
- (IBAction)sendMsg:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UILabel *sug1;
@property (weak, nonatomic) IBOutlet UILabel *sug2;
@property (weak, nonatomic) IBOutlet UILabel *sug3;

// User name
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *userEmail;
@property (nonatomic) BOOL userType;

@end

@implementation SettingsViewController {
    NSMutableArray <ChatMessage *> *tableData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    tableData = [NSMutableArray new];
    
    // Initialize user settings
    self.userName = @"Krishna";
    self.userEmail = @"krishna@krishna.online";
    self.userType = YES;

    
//    self.view.backgroundColor = [UIColor clearColor];
    
    __unused NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getAllMessages) userInfo:nil repeats:YES];
    
    [self joinAsUser];
    
    [self getAllMessages];
}

#pragma mark user methods

-(void)joinAsUser
{
    //Connect to server as user with name and email
    //POST
    //Format user String
    //    http://52.1.178.33:8080/chat/user?name=krishna&email=krishnar@gmail.com

    
    NSString *userURL = [NSString stringWithFormat:@"http://52.1.178.33:8080/chat/user"];
    
    //    Connect
    NSURL *url = [NSURL URLWithString:userURL];
    //    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *post =[NSString stringWithFormat:@"email=%@&name=%@", self.userEmail, self.userName];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *str=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    NSLog(@">>>Response: %@", str);
    
    
  }

-(void)userPostMessage:(ChatMessage *)message
{
    
    NSString *userURL = [NSString stringWithFormat:@"http://52.1.178.33:8080/chat/user/message"];
    
    // URL of the endpoint we're going to contact.
    NSURL *url = [NSURL URLWithString:userURL];
    
    
    NSString *post =[NSString stringWithFormat:@"message=%@", message.message];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *str=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    NSLog(@">>>Response: %@", str);
    
}


-(void)getAllMessages
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    NSLog(@"%@", iso8601String);
    
    
    NSString *userURL = [NSString stringWithFormat:@"http://52.1.178.33:8080/chat/messages?start=%@", iso8601String];
    
    //    Connect
    NSURL *url = [NSURL URLWithString:userURL];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *dataJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSLog(@"%@", dataJSON);
        
        if (dataJSON.count > tableData.count) {
            [tableData removeAllObjects];
            for (id object in dataJSON) {
                
            NSString *message = [object valueForKey:@"message"];
            NSString *senderEmail = [object valueForKeyPath:@"sender.email"];
                BOOL user = NO;
                if (senderEmail == self.userEmail) {
                    user = YES;
                } else if ([senderEmail isEqualToString: @"Julianne@gmail.com"]) {
                    user = NO;
                }
            
            ChatMessage *chatMsg = [[ChatMessage alloc] initWithMessage:message isUser:user name:nil andEmail:nil];
            [tableData addObject:chatMsg];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tableData.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
        
    }];
    [dataTask resume];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    ChatMessage *chatMessage = [tableData objectAtIndex:indexPath.row];
    
    cell.messageLabel.text = [NSString stringWithFormat:@" %@  ", chatMessage.message];
    cell.messageCloud.layer.cornerRadius = 10.0;
    cell.messageCloud.layer.masksToBounds = YES;
//    cell.messageLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    
    if (chatMessage.isUser == YES) {
        cell.leftMargin.active = NO;
//        cell.messageLabel.textAlignment = NSTextAlignmentRight;
//        cell.messageLabel.backgroundColor = [UIColor colorWithRed:1.00 green:0.81 blue:0.52 alpha:1.0];
    }
    else {
        cell.rightMargin.active = NO;
//        cell.messageLabel.textAlignment = NSTextAlignmentLeft;
//        cell.messageLabel.backgroundColor = [UIColor orangeColor];
    }
    cell.width.constant = cell.messageLabel.text.length*10;
    
    
    return cell;
}

- (IBAction)closeSettings:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)sendMsg:(id)sender {
    
    ChatMessage *chatMsg = [[ChatMessage alloc] initWithMessage:self.sendTextField.text isUser:self.userType name:nil andEmail:nil];
    [tableData addObject:chatMsg];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tableData.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self userPostMessage:chatMsg];
    
    self.sendTextField.text = @"";
    
}
@end
