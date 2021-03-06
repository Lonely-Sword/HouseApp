//
//  FavlistViewController.m
//  RentHouseProject
//
//  Created by Chenyang on 7/25/16.
//  Copyright © 2016 Chenyang. All rights reserved.
//

#import "FavlistViewController.h"
#import "CoreDataTableViewCell.h"
#import "AppDelegate.h"
#import "FavDetailViewController.h"

@interface FavlistViewController ()
- (IBAction)back_Action:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *Tbl_View;
@property (strong, nonatomic) NSMutableArray*presentArray;
@property (strong, nonatomic) NSArray*inforArray;
@end

@implementation FavlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.Tbl_View.backgroundColor = [UIColor clearColor];
    [self fetchCoreData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [self fetchCoreData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchCoreData{
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSString*uid = [defaults valueForKey:@"kuserid"];
    AppDelegate*delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext*context=[delegate managedObjectContext];
    NSFetchRequest*fetchrequest=[[NSFetchRequest alloc] initWithEntityName:@"FAVLIST"];
    _inforArray =[[context executeFetchRequest:fetchrequest error:nil]mutableCopy];
    if ([_inforArray count]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@",uid];
        NSArray*temp = [_inforArray filteredArrayUsingPredicate:predicate];
        _presentArray = [[NSMutableArray alloc] initWithArray:temp];
        [_Tbl_View reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_presentArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CoreDataTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    cell.cellNameLbl.text = [[_presentArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.cellDescLbl.text = [[_presentArray objectAtIndex:indexPath.row] valueForKey:@"desc"];
    NSString *imgString = [[_presentArray objectAtIndex:indexPath.row] valueForKey:@"imgurl"];
    NSString *str = @"";
    str = [imgString stringByReplacingOccurrencesOfString:@"\\"                                                withString:@"/"];
    NSString *string = [NSString stringWithFormat:@"http://%@",str];
    NSURL *imgUrl = [NSURL URLWithString:string];
    NSData *data = [NSData dataWithContentsOfURL:imgUrl];
    if (data) {
       cell.cellImgView.image = [UIImage imageWithData:data];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate*delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext*context=[delegate managedObjectContext];
        [context deleteObject:[_presentArray objectAtIndex:indexPath.row]];// delete from context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't delete!..%@ %@",error,[error localizedDescription]);
            return;
        }
        [_presentArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FavDetailViewController*controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FavDetailViewController"];
    [controller setFavList:_presentArray];
    [controller setFavIndex:indexPath.row];
    [self presentViewController:controller animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)back_Action:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
