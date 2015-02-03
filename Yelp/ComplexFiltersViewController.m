//
//  ComplexFiltersViewController.m
//  Yelp
//
//  Created by Shangqing Zhang on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "ComplexFiltersViewController.h"
#import "SwitchTableViewCell.h"



@interface ComplexFiltersViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ComplexFiltersViewController
{
    NSArray *_categories;
    NSArray *_distances;
    NSArray *_sort;
    
    NSMutableSet *_selectedCategories;
    
    NSMutableArray *_firstDistance;
    NSMutableArray *_firstSort;
    
    BOOL categorySectionIsExpanded;
    BOOL distanceSectionIsExpanded;
    BOOL sortSectionIsExpanded;
    
    BOOL dealSelected;
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        
        [self initCategories];
        [self initDistances];
        [self initSort];
        self.title = @"Filters";
        
        _selectedCategories = [[NSMutableSet alloc] init];
        // Do any additional setup after loading the view from its nib.
        
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(10, 0, 60, 30);
        [leftButton setTitle:@"Cancell" forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(didCancelTapped) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = btn;
        
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        rightButton.frame = CGRectMake(self.view.frame.size.width - 90, 0, 60, 30);
        [rightButton setTitle:@"Apply" forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(didSearchTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rightButton];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = btn2;
        
        
        
        
        self.tableView.dataSource =self;
        self.tableView.delegate = self;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        UINib *movieCellNib = [UINib nibWithNibName:@"SwitchTableViewCell" bundle:nil];
        [self.tableView registerNib:movieCellNib forCellReuseIdentifier:@"SwitchTableViewCell"];
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];
    
    
}

- (void)didCancelTapped
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSearchTapped
{
    
    NSString *dealString = dealSelected ? @"true" : @"yes";
    NSString *distanceString = _firstDistance[0][@"code"];
    NSString *sortString = _firstSort[0][@"code"];
    NSString *categoryString = [[_selectedCategories allObjects] componentsJoinedByString:@","];
    
    [self.delegate searchForCategory:categoryString
                                sort:sortString
                            distance:distanceString
                                deal:dealString];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)unExpand
{
    categorySectionIsExpanded = NO;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

#pragma mark - SwitchTableViewControllerDelegate

-(void)didSelectCodeLabel:(NSString *)codeLabel
{
    if ([codeLabel isEqualToString:@"deal"]) {
        dealSelected = YES;
        return;
    }
    if (![_selectedCategories containsObject:codeLabel]) {
        [_selectedCategories addObject:codeLabel];
    }
}

-(void)didDeselectCodeLabel:(NSString *)codeLabel
{
    if ([codeLabel isEqualToString:@"deal"]) {
        dealSelected = NO;
        return;
    }
    
    if ([_selectedCategories containsObject:codeLabel]) {
        [_selectedCategories delete:codeLabel];
    }
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (categorySectionIsExpanded) {
            return [_categories count];
        } else {
            return 4;
        }
    } else if (section == 1) {
        if (distanceSectionIsExpanded) {
            return [_distances count];
        } else {
            return [_firstDistance count];
        }
    } else if (section == 2) {
        if (sortSectionIsExpanded) {
            return [_sort count];
        } else {
            return [_firstSort count];
        }
    } else if (section == 3) {
        return 1;
    }
    
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 20;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    NSString *string;
    
    if (section == 0) {
        string = @"Categories";
    } else if (section == 1) {
        string = @"Distance";
    } else if (section == 2) {
        string = @"Sort By";
    } else {
        string = @"Deals";
    }
    
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    
    if (section == 0) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(230, 0, 80, 30)];
        [btn setTitle:@"Hide" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(unExpand) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    
    
    [view setBackgroundColor:[UIColor lightTextColor]];
    
    return view;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (!categorySectionIsExpanded && indexPath.row == 3) {
            categorySectionIsExpanded = YES;
            [self.tableView reloadData];
        }
    } else if (indexPath.section == 1) {
        
        if (distanceSectionIsExpanded) {
            _firstDistance[0] = [_distances[indexPath.row] mutableCopy];
            
        }
        distanceSectionIsExpanded = !distanceSectionIsExpanded;
        [tableView reloadData];
    } else if (indexPath.section == 2) {
        if (sortSectionIsExpanded) {
            _firstSort[0] = [_sort[indexPath.row] mutableCopy];
        }
        sortSectionIsExpanded = ! sortSectionIsExpanded;
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([cell isKindOfClass:[SwitchTableViewCell class]]) {
            SwitchTableViewCell *myCell = (SwitchTableViewCell *) cell;
            
            NSString *codeString = _categories[indexPath.row][@"code"];
            [myCell.mySwitch setOn: [_selectedCategories containsObject:codeString]];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (categorySectionIsExpanded || indexPath.row <3) {
            SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchTableViewCell" forIndexPath:indexPath];
            
            cell.descriptionLabel.text = _categories[indexPath.row][@"name"];
            
            NSString *codeString = _categories[indexPath.row][@"code"];
            cell.delegate = self;
            
            [cell.mySwitch setOn:[_selectedCategories containsObject:codeString ]];
            cell.codeLabel.text = codeString;
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"See more";
            return cell;
        }
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        if (distanceSectionIsExpanded) {
            cell.textLabel.text = _distances[indexPath.row][@"name"];
        } else {
            cell.textLabel.text = _firstDistance[indexPath.row][@"name"];
        }
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        if (sortSectionIsExpanded) {
            cell.textLabel.text = _sort[indexPath.row][@"name"];
        } else {
            cell.textLabel.text = _firstSort[indexPath.row][@"name"];
        }
        return cell;
    } else if (indexPath.section == 3) {
        SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchTableViewCell" forIndexPath:indexPath];
        cell.descriptionLabel.text = @"Deals";
        cell.codeLabel.text = @"deal";
        
        cell.delegate = self;
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"Something";
    return cell;
}


- (void)initSort
{
    _firstSort = [@[@{@"name" : @"Best matched", @"code": @"0"}] mutableCopy];
    _sort = @[
              @{@"name" : @"Best matched", @"code": @"0"},
              @{@"name" : @"Distance", @"code": @"1"},
              @{@"name" : @"Highest Rated", @"code": @"2"},
              ];
}
- (void)initDistances
{
    _firstDistance = [@[@{@"name" : @"Auto", @"code": @"1000"}] mutableCopy];
    
    _distances = @[@{@"name" : @"Auto", @"code": @"1000"},
                   @{@"name" : @"0.3 miles", @"code": @"300" },
                   @{@"name" : @"0.6 miles", @"code": @"600" },
                   @{@"name" : @"1 mile", @"code": @"1000" },
                   @{@"name" : @"5 miles", @"code": @"5000" },
                   @{@"name" : @"10 miles", @"code": @"10000" },
                   ];
}

- (void)initCategories
{
    _categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                    @{@"name" : @"African", @"code": @"african" },
                    @{@"name" : @"American, New", @"code": @"newamerican" },
                    @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                    @{@"name" : @"Arabian", @"code": @"arabian" },
                    @{@"name" : @"Argentine", @"code": @"argentine" },
                    @{@"name" : @"Armenian", @"code": @"armenian" },
                    @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                    @{@"name" : @"Asturian", @"code": @"asturian" },
                    @{@"name" : @"Australian", @"code": @"australian" },
                    @{@"name" : @"Austrian", @"code": @"austrian" },
                    @{@"name" : @"Baguettes", @"code": @"baguettes" },
                    @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                    @{@"name" : @"Barbeque", @"code": @"bbq" },
                    @{@"name" : @"Basque", @"code": @"basque" },
                    @{@"name" : @"Bavarian", @"code": @"bavarian" },
                    @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                    @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                    @{@"name" : @"Beisl", @"code": @"beisl" },
                    @{@"name" : @"Belgian", @"code": @"belgian" },
                    @{@"name" : @"Bistros", @"code": @"bistros" },
                    @{@"name" : @"Black Sea", @"code": @"blacksea" },
                    @{@"name" : @"Brasseries", @"code": @"brasseries" },
                    @{@"name" : @"Brazilian", @"code": @"brazilian" },
                    @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                    @{@"name" : @"British", @"code": @"british" },
                    @{@"name" : @"Buffets", @"code": @"buffets" },
                    @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                    @{@"name" : @"Burgers", @"code": @"burgers" },
                    @{@"name" : @"Burmese", @"code": @"burmese" },
                    @{@"name" : @"Cafes", @"code": @"cafes" },
                    @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                    @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                    @{@"name" : @"Cambodian", @"code": @"cambodian" },
                    @{@"name" : @"Canadian", @"code": @"New)" },
                    @{@"name" : @"Canteen", @"code": @"canteen" },
                    @{@"name" : @"Caribbean", @"code": @"caribbean" },
                    @{@"name" : @"Catalan", @"code": @"catalan" },
                    @{@"name" : @"Chech", @"code": @"chech" },
                    @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                    @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                    @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                    @{@"name" : @"Chilean", @"code": @"chilean" },
                    @{@"name" : @"Chinese", @"code": @"chinese" },
                    @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                    @{@"name" : @"Corsican", @"code": @"corsican" },
                    @{@"name" : @"Creperies", @"code": @"creperies" },
                    @{@"name" : @"Cuban", @"code": @"cuban" },
                    @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                    @{@"name" : @"Cypriot", @"code": @"cypriot" },
                    @{@"name" : @"Czech", @"code": @"czech" },
                    @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                    @{@"name" : @"Danish", @"code": @"danish" },
                    @{@"name" : @"Delis", @"code": @"delis" },
                    @{@"name" : @"Diners", @"code": @"diners" },
                    @{@"name" : @"Dumplings", @"code": @"dumplings" },
                    @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                    @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                    @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                    @{@"name" : @"Filipino", @"code": @"filipino" },
                    @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                    @{@"name" : @"Fondue", @"code": @"fondue" },
                    @{@"name" : @"Food Court", @"code": @"food_court" },
                    @{@"name" : @"Food Stands", @"code": @"foodstands" },
                    @{@"name" : @"French", @"code": @"french" },
                    @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                    @{@"name" : @"Galician", @"code": @"galician" },
                    @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                    @{@"name" : @"Georgian", @"code": @"georgian" },
                    @{@"name" : @"German", @"code": @"german" },
                    @{@"name" : @"Giblets", @"code": @"giblets" },
                    @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                    @{@"name" : @"Greek", @"code": @"greek" },
                    @{@"name" : @"Halal", @"code": @"halal" },
                    @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                    @{@"name" : @"Heuriger", @"code": @"heuriger" },
                    @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                    @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                    @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                    @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                    @{@"name" : @"Hungarian", @"code": @"hungarian" },
                    @{@"name" : @"Iberian", @"code": @"iberian" },
                    @{@"name" : @"Indian", @"code": @"indpak" },
                    @{@"name" : @"Indonesian", @"code": @"indonesian" },
                    @{@"name" : @"International", @"code": @"international" },
                    @{@"name" : @"Irish", @"code": @"irish" },
                    @{@"name" : @"Island Pub", @"code": @"island_pub" },
                    @{@"name" : @"Israeli", @"code": @"israeli" },
                    @{@"name" : @"Italian", @"code": @"italian" },
                    @{@"name" : @"Japanese", @"code": @"japanese" },
                    @{@"name" : @"Jewish", @"code": @"jewish" },
                    @{@"name" : @"Kebab", @"code": @"kebab" },
                    @{@"name" : @"Korean", @"code": @"korean" },
                    @{@"name" : @"Kosher", @"code": @"kosher" },
                    @{@"name" : @"Kurdish", @"code": @"kurdish" },
                    @{@"name" : @"Laos", @"code": @"laos" },
                    @{@"name" : @"Laotian", @"code": @"laotian" },
                    @{@"name" : @"Latin American", @"code": @"latin" },
                    @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                    @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                    @{@"name" : @"Malaysian", @"code": @"malaysian" },
                    @{@"name" : @"Meatballs", @"code": @"meatballs" },
                    @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                    @{@"name" : @"Mexican", @"code": @"mexican" },
                    @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                    @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                    @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                    @{@"name" : @"Modern European", @"code": @"modern_european" },
                    @{@"name" : @"Mongolian", @"code": @"mongolian" },
                    @{@"name" : @"Moroccan", @"code": @"moroccan" },
                    @{@"name" : @"New Zealand", @"code": @"newzealand" },
                    @{@"name" : @"Night Food", @"code": @"nightfood" },
                    @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                    @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                    @{@"name" : @"Oriental", @"code": @"oriental" },
                    @{@"name" : @"Pakistani", @"code": @"pakistani" },
                    @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                    @{@"name" : @"Parma", @"code": @"parma" },
                    @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                    @{@"name" : @"Peruvian", @"code": @"peruvian" },
                    @{@"name" : @"Pita", @"code": @"pita" },
                    @{@"name" : @"Pizza", @"code": @"pizza" },
                    @{@"name" : @"Polish", @"code": @"polish" },
                    @{@"name" : @"Portuguese", @"code": @"portuguese" },
                    @{@"name" : @"Potatoes", @"code": @"potatoes" },
                    @{@"name" : @"Poutineries", @"code": @"poutineries" },
                    @{@"name" : @"Pub Food", @"code": @"pubfood" },
                    @{@"name" : @"Rice", @"code": @"riceshop" },
                    @{@"name" : @"Romanian", @"code": @"romanian" },
                    @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                    @{@"name" : @"Rumanian", @"code": @"rumanian" },
                    @{@"name" : @"Russian", @"code": @"russian" },
                    @{@"name" : @"Salad", @"code": @"salad" },
                    @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                    @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                    @{@"name" : @"Scottish", @"code": @"scottish" },
                    @{@"name" : @"Seafood", @"code": @"seafood" },
                    @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                    @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                    @{@"name" : @"Singaporean", @"code": @"singaporean" },
                    @{@"name" : @"Slovakian", @"code": @"slovakian" },
                    @{@"name" : @"Soul Food", @"code": @"soulfood" },
                    @{@"name" : @"Soup", @"code": @"soup" },
                    @{@"name" : @"Southern", @"code": @"southern" },
                    @{@"name" : @"Spanish", @"code": @"spanish" },
                    @{@"name" : @"Steakhouses", @"code": @"steak" },
                    @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                    @{@"name" : @"Swabian", @"code": @"swabian" },
                    @{@"name" : @"Swedish", @"code": @"swedish" },
                    @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                    @{@"name" : @"Tabernas", @"code": @"tabernas" },
                    @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                    @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                    @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                    @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                    @{@"name" : @"Thai", @"code": @"thai" },
                    @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                    @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                    @{@"name" : @"Trattorie", @"code": @"trattorie" },
                    @{@"name" : @"Turkish", @"code": @"turkish" },
                    @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                    @{@"name" : @"Uzbek", @"code": @"uzbek" },
                    @{@"name" : @"Vegan", @"code": @"vegan" },
                    @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                    @{@"name" : @"Venison", @"code": @"venison" },
                    @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                    @{@"name" : @"Wok", @"code": @"wok" },
                    @{@"name" : @"Wraps", @"code": @"wraps" },
                    @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
}

@end
