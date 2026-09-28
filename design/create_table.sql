-- Design part: table for the Occluded-Pedestrian records of Labels.csv.
-- Column names match the CSV header one-to-one so the Pub/Sub -> MySQL sink
-- connector maps each JSON field straight onto a column. Timestamp is the
-- primary key (the connector's Create operation inserts by primary key).
use Readings;

create table Pedestrian(
  Timestamp double primary key,
  Car1_Location_X double, Car1_Location_Y double,
  Car1_Length double, Car1_Width double, Car1_Height double,
  Car2_Location_X double, Car2_Location_Y double,
  Car2_Length double, Car2_Width double, Car2_Height double,
  pedestrian_Location_X double, pedestrian_Location_Y double,
  pedestrian_Length double, pedestrian_Width double, pedestrian_Height double,
  cam1_pedestrian_x1 double, cam1_pedestrian_y1 double,
  cam1_pedestrian_x2 double, cam1_pedestrian_y2 double,
  cam2_car_x1 double, cam2_car_y1 double, cam2_car_x2 double, cam2_car_y2 double,
  cam3_pedestrian_x1 double, cam3_pedestrian_y1 double,
  cam3_pedestrian_x2 double, cam3_pedestrian_y2 double,
  Occluded_Image_View varchar(100), Occluded_Image_Lidar varchar(100),
  Occluding_Image_View varchar(100), Occluding_Image_Lidar varchar(100),
  Ground_Truth_View varchar(100)
);
