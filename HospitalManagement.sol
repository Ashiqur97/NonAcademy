// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HospitalManagement {
    struct Patient {
        uint id;
        string name;
        string medicalHistory;
    }

    struct Doctor {
        uint id;
        string name;
        string specialty;
    }

    struct Appointment {
        uint id;
        uint patientId;
        uint doctorId;
        uint date;
        bool isConfirmed;
    }

    Patient[] public patients;
    Doctor[] public doctors;
    Appointment[] public appointments;


    function addPatient(string memory _name, string memory _medicalHistory) public {
        uint patientId = patients.length;
        patients.push(Patient(patientId,_name,_medicalHistory));
    }

    function addDoctor(string memory _name, string memory _specialty) public {
        uint doctorId = doctors.length;
        doctors.push(Doctor(doctorId,_name,_specialty));
    }

    function schduleAppointment(uint _patientId,uint _doctorId,uint _date) public {
        require(_patientId < patients.length, "Invalid Patient Id");
        require(_doctorId < doctors.length, "Invalid Doctor Id");

        appointments.push(Appointment(appointments.length,_doctorId,_patientId,_date,false));
    }

    function confirmedAppointment(uint _appointmentId) public {
        require(_appointmentId < appointments.length,"Invalid Appointment Id");
        appointments[_appointmentId].isConfirmed = true;
    }

    function getAllPatients() public  view returns(Patient[] memory) {
        return patients;
    }

    function getAllDoctors() public view returns(Doctor[] memory) {
        return doctors;
    }

    function getAllAppointments() public view returns(Appointment[] memory) {
        return appointments;
    }
}
