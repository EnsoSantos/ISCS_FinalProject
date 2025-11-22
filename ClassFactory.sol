// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract ClassFactory {

    address private professor;
    
    ClassContract[] public deployedClasses;

    event DeployedClasses(
        address indexed classAddress,
        string _name,
        uint scholarshipMinimum
    );

        constructor() {
        professor = msg.sender;
    }

    function createClass(
        string memory _name,
        uint scholarshipMinimum
    ) public {
        require(msg.sender == professor, "Only a professor can create a class.");

        ClassContract newClass = new ClassContract(_name, scholarshipMinimum, professor);
        deployedClasses.push(newClass);

        emit DeployedClasses(address(newClass), _name, scholarshipMinimum);
    }

    function getDeployedClasses() public view returns (ClassContract[] memory) {
        return deployedClasses;
    }


}

contract ClassContract {

    struct AttendanceRecord {
        //(stores history if Present or Not + timestamp) mapping(student => AttendanceRecord[]) records mapping(student => int merit) meritScore
        uint sessionNo;
        string status; // present, absent and stuff
        uint timestamp;
    }

    struct Student {
        string name;
        address studentAddress;
        bool scholarshipIsEligible;
    }

    mapping(address => AttendanceRecord[]) public attendanceRecords;
        
    //scholarshipMinimum => int
    //scholarshipIsEligible[student] => bool
    mapping(address => int) public meritScore;
    mapping(address => bool) public scholarshipIsEligible;

    string public name;
    uint public scholarshipMinimum;
    address public professor;

    struct SessionConfig{
        uint startTime;
        uint lateAfter;
        uint endTime;
        bool exists;
    }
    mapping(uint => SessionConfig) public sessionConfigs;

    constructor(string memory _name, uint _scholarshipMinimum, address _professor) {
        /// Runs based when the class contract is created then initializes the variables like which class or prof or smth
        name = _name;
        scholarshipMinimum = _scholarshipMinimum;
        professor = _professor;
    }

    modifier isProfessor() {
        require(msg.sender == professor, "You are not the Professor.");
        _;
    }

    modifier isStudent() {
        require(msg.sender != professor, "You are not a Student.");
        _;
    }

    //forda late after 
    function setSessionTimes(uint sessionNo, uint startTime, uint lateAfter, uint endTime) public isProfessor{
        require(startTime < lateAfter, "startTime must be before lateAfter");
        require(lateAfter < endTime, "lateAfter must be before endTime");
        sessionConfigs[sessionNo] = SessionConfig({
            startTime: startTime,
            lateAfter: lateAfter,
            endTime: endTime,
            exists: true
        });
    }  

    function markAbsent(uint sessionNo, address student) public isProfessor {//based on the session
        /// Mark absent with timestamp
        ///-2 in meritScore kasi late will -1
        AttendanceRecord memory record = AttendanceRecord({
            sessionNo: sessionNo,
            status: "Absent",
            timestamp: block.timestamp
        });
        attendanceRecords[student].push(record);
        meritScore[student] -=2;
    }
    
    function markPresent(uint sessionNo) public{
        //Mark present with timestamp
        //+1 meritScore
        address student = msg.sender;
        SessionConfig memory config = sessionConfigs[sessionNo];
        require(config.exists, "Session times not set");

        //If someone wants to check in before the class (Like days before)
        require(block.timestamp >= config.startTime, "Too early to check in");
        //If its too late
        require(block.timestamp <= config.endTime, "Too late to check in");

        string memory status;
        if (block.timestamp <= config.lateAfter) {
            // On time
            status = "Present";
            meritScore[student] += 1;  // +1 if on time
        } else {
            // Still allowed to check in, but now counted as late
            status = "Late";
            meritScore[student] -= 1;  // -1 if late
        }

        AttendanceRecord memory record = AttendanceRecord({
            sessionNo: sessionNo,
            status: status,
            timestamp: block.timestamp
        });
        attendanceRecords[student].push(record);
    }


    function markLate(uint sessionNo, address student) public isProfessor{
        //Mark late with timestamp
        //-1 merit score
        //Initially planning to store like a startTime, lateAfter, etc so that a late student will not cheat and mark themselves present 
        AttendanceRecord memory record = AttendanceRecord({
            sessionNo: sessionNo,
            status: "Late",
            timestamp: block.timestamp
    });

        attendanceRecords[student].push(record);
        meritScore[student] -=1;
    }

    function setExcused(uint sessionNo, address student) public isProfessor {
        //Mark Excused with timestamp
        //No merits and demerits
        AttendanceRecord memory record = AttendanceRecord({
            sessionNo: sessionNo,
            status: "Excused",
            timestamp: block.timestamp
        });
        attendanceRecords[student].push(record);

    }

    function getRecord(address student, uint sessionIndex) public view returns(AttendanceRecord memory){
        //Returns the AttendanceRecord of student on a certain session like if late or absent siya in session 3 or smth
        require(sessionIndex < attendanceRecords[student].length, "Invalid session index");
        return attendanceRecords[student][sessionIndex];
    }

    function getMerit(address student) public view returns (int){
        //Returns the meritScore
        return meritScore[student];
    }

    function checkScholarship(address student) public returns (bool){
        //Check if meritScore >= scholarshipMinimum
        bool eligible = meritScore[student] >= int(scholarshipMinimum);
        scholarshipIsEligible[student] = eligible;
        return eligible;
    }   

}