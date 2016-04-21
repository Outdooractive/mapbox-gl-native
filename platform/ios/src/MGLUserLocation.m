#import "MGLUserLocation_Private.h"

#import "MGLMapView.h"
#import "NSBundle+MGLAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface MGLUserLocation ()

@property (nonatomic, weak) MGLMapView *mapView;

@end

NS_ASSUME_NONNULL_END

@implementation MGLUserLocation

- (instancetype)initWithMapView:(MGLMapView *)mapView
{
    if (self = [super init])
    {
        _location = [[CLLocation alloc] initWithLatitude:MAXFLOAT longitude:MAXFLOAT];
        _mapView = mapView;
    }

    return self;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return ! [key isEqualToString:@"location"] && ! [key isEqualToString:@"heading"];
}

+ (NS_SET_OF(NSString *) *)keyPathsForValuesAffectingCoordinate
{
    return [NSSet setWithObject:@"location"];
}

- (void)setLocation:(CLLocation *)newLocation
{
    if ( ! newLocation || ! CLLocationCoordinate2DIsValid(newLocation.coordinate)) return;
    if ( _location && CLLocationCoordinate2DIsValid(_location.coordinate) && [newLocation distanceFromLocation:_location] == 0) return;
    if (newLocation.coordinate.latitude == 0 && newLocation.coordinate.longitude == 0) return;

    [self willChangeValueForKey:@"location"];
    _location = newLocation;
    [self didChangeValueForKey:@"location"];
}

- (BOOL)isUpdating
{
    return self.mapView.userTrackingMode != MGLUserTrackingModeNone;
}

- (void)setHeading:(CLHeading *)newHeading
{
    if (newHeading.trueHeading != _heading.trueHeading)
    {
        [self willChangeValueForKey:@"heading"];
        _heading = newHeading;
        [self didChangeValueForKey:@"heading"];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)title
{
    return _title ?: NSLocalizedString(@"You Are Here", @"Default user location annotation title");
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; location = %f, %f; updating = %@; altitude = %.0fm; heading = %.0f°; title = %@; subtitle = %@>",
            NSStringFromClass([self class]), (void *)self,
            self.location.coordinate.latitude, self.location.coordinate.longitude,
            self.updating ? @"yes" : @"no",
            self.location.altitude,
            self.heading.trueHeading,
            self.title ? [NSString stringWithFormat:@"\"%@\"", self.title] : self.title,
            self.subtitle ? [NSString stringWithFormat:@"\"%@\"", self.subtitle] : self.subtitle];
}

@end
