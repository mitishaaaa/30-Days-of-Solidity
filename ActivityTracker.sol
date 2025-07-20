// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker{

    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;
    }

    struct WorkoutActivity{
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }

mapping(address => UserProfile) public userProfiles; //Stores a profile for each user (by their address)
mapping(address => WorkoutActivity[]) private workoutHistory; //Keeps an array of workout logs per user
mapping(address => uint256) public totalWorkouts; //Tracks how many workouts each user has logged
mapping(address => uint256) public totalDistance; //Tracks the total distance a user has covered

event UserRegistered(
    address indexed userAddress,
    string name, 
    uint256 timestamp
);

event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);

event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);

event MilestoneAchieved(address indexed userAddress, string milestione, uint256 timestamp);


modifier onlyRegistered(){
    require(userProfiles[msg.sender].isRegistered, "User not registered");
    _;
}

function registerUser(string memory _name, uint256 _weight) public{
    require(!userProfiles[msg.sender].isRegistered, "User already registered");

    userProfiles[msg.sender] = UserProfile({
        name: _name,
        weight: _weight,
        isRegistered: true
    });

    emit UserRegistered(msg.sender, _name, block.timestamp);
}

function updateWeight(uint256 _newWeight) public onlyRegistered{
    UserProfile storage profile = userProfiles[msg.sender];

    if(_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5){
        emit MilestoneAchieved(msg.sender, "Weight goal reached", block.timestamp);
 }

 profile.weight = _newWeight;
 emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
}


function logWorkout(
    string memory _activityType,
    uint256 _duration,
    uint256 _distance) public onlyRegistered{

       // Record the Workout in a Struct
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        

        //Store the Workout in the User’s History
        workoutHistory[msg.sender].push(newWorkout);

        //Update total stats
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;

        // emit the workout
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp);
        

    // Check for workout count milestone
    if(totalWorkouts[msg.sender] == 10){
        emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
    }  else if (totalWorkouts[msg.sender] == 50){
        emit MilestoneAchieved(msg.sender, "50 workouts completed", block.timestamp);
    }

    // We also check if the user crossed 100K kilometers total distance:
     if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
    emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
  } 
}
    
    // getUserWorkCOunt()
    function getUserWorkoutCount() public view onlyRegistered returns(uint256)
{
    return workoutHistory[msg.sender].length;
}    

}
