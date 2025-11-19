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
        string _name,
        uint scholarshipMinimum
    ) public {
        require(msg.sender == professor, "Only a professor can create a class.");

        ClassContract newClass = new ClassContract(_name, scholarshipMinimum);
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
    }

    struct Student {
        string name;
        address studentAddress;
        bool scholarshipIsEligible;
    }

    mapping(address => AttendanceRecord) public attendanceRecords;

        
    //scholarshipMinimum => int
    //scholarshipIsEligible[student] => bool

    constructor(
        /// Runs based when the class contract is created then initializes the variables like which class or prof or smth
    ) 

    modifier isProfessor() {
        require(msg.sender == professor, "You are not the Professor.");
        _;
    }

    modifier isStudent() {
        require(msg.sender == organizer, "You are not a Student.");
        _;
    }

    function markAbsent(sessionNo, student) {//based on the session
        /// Mark absent with timestamp
        ///-2 in meritScore kasi late will -1
    }
    
    function markPresent(sessionNo) {
        //Mark present with timestamp
        //+1 meritScore
    }


    function markLate(sessionNo, student){
        //Mark late with timestamp
        //-1 merit score
        //Initially planning to store like a startTime, lateAfter, etc so that a late student will not cheat and mark themselves present 
    }

    function setExcused(sessionNo, student) {
        //Mark Excused with timestamp
        //No merits and demerits
    }

    function getRecord(student, sessionNo) {
        //Returns the AttendanceRecord of student on a certain session like if late or absent siya in session 3 or smth
    }

    function getMerit(student){
        //Returns the meritScore
    }

    function checkScholarship(student){
        //Check if meritScore >= scholarshipMinimum
    }   

}