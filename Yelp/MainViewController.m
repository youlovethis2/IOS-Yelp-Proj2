//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"


NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BusinessCell *prototypeCell;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;


@property (nonatomic, copy) NSString *categoryFilterString;
@property (nonatomic, copy) NSString *dealFilterString;
@property (nonatomic, copy) NSString *sortFilterString;
@property (nonatomic, copy) NSString *distanceFilterString;


- (void)fetchBusinessWithQuery: (NSString *)query params: (NSDictionary *)params;
@end

@implementation MainViewController


- (void)searchForText:(NSString *)searchText
{
    [self.client searchWithTerm:searchText
                       category:_categoryFilterString
                       distance:_distanceFilterString
                           sort:_sortFilterString
                           deal:_dealFilterString
                        success:^(AFHTTPRequestOperation *operation, id response) {
                           //h NSLog(@"response: %@", response);
                            
                           
                            NSArray *businessDictionaries = response[@"businesses"];
                            self.businesses = [Business businessWithDictionaries:businessDictionaries];
                            NSLog(@"%d",self.businesses.count);
                            if(self.businesses.count>0){
                                [self.tableView reloadData];
                            }
                            
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"error: %@", [error description]);
                        }];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        //[self fetchBusinessWithQuery:@"Restaurants" params:nil];
         [self searchForText:@"Restaurants"];
        UISearchBar *label = [[UISearchBar alloc] initWithFrame:CGRectMake(100,000, 200,30)];
        
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(50, 0, 200, 30)];
        [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        
        self.searchBar.delegate = self;
        
        self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        [self.searchController setDelegate:self];
        [self.searchController setSearchResultsDataSource:self];
        [self.searchController setSearchResultsDelegate:self];
        
        
        self.navigationItem.titleView = self.searchController.searchBar;
      
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
 
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.title = @"Yelp";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    
    // Do any additional setup after loading the view from its nib.
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.businesses.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;

}


- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters{
    [self fetchBusinessWithQuery:@"Restaurant" params:filters];
    NSLog(@"fire new network event %@", filters);
    
}

- (BusinessCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    }
    return _prototypeCell;
}



- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void) fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params{
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response){
       
        NSArray *businessDictionaries = response[@"businesses"];
        self.businesses = [Business businessWithDictionaries:businessDictionaries];
        [self.tableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"error: %@",[error description]);
    }];
}


#pragma mark - Private methods

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchtext : %@", searchText);
    [self searchForText:searchText];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}







@end
