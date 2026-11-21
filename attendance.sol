// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AttendanceRecord {
    address public instructor;
    string public courseTitle;

    mapping(address => bool) public hasAttended;
    address[] public attendees;

    event AttendanceRecorded(address indexed student, uint256 timestamp);
    event AttendanceRemoved(address indexed student);

    constructor(string memory _courseTitle) {
        instructor = msg.sender;
        courseTitle = _courseTitle;
    }

    modifier onlyInstructor() {
        require(msg.sender == instructor, "Only the instructor can perform this action.");
        _;
    }

    // Records a student's attendance once and prevents duplicate entries.
    function recordAttendance(address _student) external onlyInstructor {
        require(_student != address(0), "Invalid student address.");
        require(!hasAttended[_student], "Student is already recorded.");

        hasAttended[_student] = true;
        attendees.push(_student);

        emit AttendanceRecorded(_student, block.timestamp);
    }

    // Returns the total number of students currently recorded as attending.
    function getAttendeeCount() external view returns (uint256) {
        return attendees.length;
    }

    // Checks whether a given student address is currently marked as attending.
    function isAttending(address _student) external view returns (bool) {
        return hasAttended[_student];
    }

    // Removes an attending student's record so they can be recorded again; restricted to the instructor.
    function removeAttendance(address _student) external onlyInstructor {
        require(hasAttended[_student], "Student has not attended.");

        hasAttended[_student] = false;

        for (uint256 i = 0; i < attendees.length; i++) {
            if (attendees[i] == _student) {
                attendees[i] = attendees[attendees.length - 1];
                attendees.pop();
                break;
            }
        }

        emit AttendanceRemoved(_student);
    }

    // Returns the complete list of currently attending student addresses.
    function getAttendees() external view returns (address[] memory) {
        return attendees;
    }
}