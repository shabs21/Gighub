// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract JobFactory {
    struct PublicJob {
        uint256 jobId;
        string companyName;
        string position;
        string description;
        string employmentType;
        string location;
        string companyUrl;
        address employer;
    }

    PublicJob publicJob;

    mapping(address => address[]) internal applicants;

    constructor(
        uint256 _jobId,
        string memory _companyName,
        string memory _position,
        string memory _description,
        string memory _employmentType,
        string memory _location,
        string memory _companyUrl,
        address _employer
    ) {
        publicJob = PublicJob({
            jobId: _jobId,
            companyName: _companyName,
            position: _position,
            description: _description,
            employmentType: _employmentType,
            location: _location,
            companyUrl: _companyUrl,
            employer: _employer
        });
    }

    function getPublicJob() external view returns (PublicJob memory) {
        return publicJob;
    }

    function jobApplication(address _jobAddress, address _applicant) public {
        applicants[_jobAddress].push(_applicant);
    }

    modifier onlyJobOwner(address _employer) {
        require(
            publicJob.employer == _employer,
            "Must be the employer of the gig to access the applicants"
        );
        _;
    }

    function getApplicants(
        address _jobAddress,
        address _employer
    ) external view returns (address[] memory) {
        address[] memory _applicantAddresses = applicants[_jobAddress];
        return _applicantAddresses;
    }
}

contract GigHub {
    address admin;
    address[] jobAddresses;
    uint256 jobId;

    constructor() {
        admin = msg.sender;
        jobId = 0;
    }

    function postPublicJob(
        string memory _companyName,
        string memory _position,
        string memory _description,
        string memory _employmentType,
        string memory _location,
        string memory _companyUrl
    ) public {
        address _jobAddress;

        JobFactory _gigJob = new JobFactory(
            jobId,
            _companyName,
            _position,
            _description,
            _employmentType,
            _location,
            _companyUrl,
            msg.sender
        );
        _jobAddress = address(_gigJob);
        jobAddresses.push(_jobAddress);
        jobId++;
    }

    function fetchMsgSender() public view returns (address) {
        return msg.sender;
    }

    JobFactory.PublicJob[] publicJobs;

    function getPublicJob() public returns (JobFactory.PublicJob[] memory) {
        if (publicJobs.length <= jobAddresses.length) {
            for (uint256 i = publicJobs.length; i < jobAddresses.length; i++) {
                publicJobs.push(JobFactory(jobAddresses[i]).getPublicJob());
            }
            return publicJobs;
        } else {
            return publicJobs;
        }
    }

    function applyPublicJob(address _jobAddress) public {
        JobFactory(_jobAddress).jobApplication(_jobAddress, msg.sender);
    }

    function fetchApplicants(
        address _jobAddress
    ) public returns (address[] memory) {
        return JobFactory(_jobAddress).getApplicants(_jobAddress, msg.sender);
    }

    function getJobAddresses() public returns (address[] memory) {
        return jobAddresses;
    }
}
