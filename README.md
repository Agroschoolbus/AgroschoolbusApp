
<img width="150" height="207" alt="AGROSCHOOL BUS LOGO 1-01_edited" src="https://github.com/user-attachments/assets/6c0aae28-247a-484f-bcaf-95585199acc6" />

# Agroschoolbus
## _Logistics system for the transportation of olives to the olive mill._
This software was developed on behalf of [ICCS](https://www.iccs.gr/) for the project [Agroschoolbus](https://www.agroschoolbus.gr/)

3 distinct applications

### Producer application
-  Display of the logged user's POIs (Points of interest)
-  Addition of new POIs manually or using GPS
-  Display of the logged user's POIs status updates

Source: [https://github.com/Agroschoolbus/AgroschoolbusApp/tree/producer](https://github.com/Agroschoolbus/AgroschoolbusApp/tree/producer)

### Transporter application
- Display of POIs
- Route creation for automated selection of POIs
- Creation of an optimized route
- Routing using GPS service
- Status update of points
- Creation of a new path in areas outside the mapped road network

Source: https://github.com/Agroschoolbus/AgroschoolbusApp/tree/transporter_v1


### Olive mill application
- Display of POIs
- Supervision of the current transporter's route
- Supervision of the current transporter's position
- Display of POI status updates

Source: https://github.com/Agroschoolbus/AgroschoolbusApp/tree/factory_v1


## Backend

### Django API
- Metadata of ROIs
- Producer's info
- Transporter's route info
Source: https://github.com/Agroschoolbus/api


## Technologies

| Software | description | Link |
| ------ | ------ | ------ |
| Flutter | Applications | https://flutter.dev/ |
| Django | Database - API | https://www.djangoproject.com/ |
| OSRM | Routing engine | https://project-osrm.org/ |


