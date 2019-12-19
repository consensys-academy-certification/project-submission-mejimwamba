pragma solidity ^0.5.0;

contract ProjectSubmission { // Step 1

    address payable public owner;//...owner...  Step 1 (state variable)//
    uint public ownerBalance; // ...ownerBalance... // Step 4 (state variable)
    uint public projectCount = 0;
    modifier onlyOwner() { // Step 1
        require(msg.sender == owner);
    _;
    }

    constructor()
    public
    {
        owner = msg.sender;
    }

    struct University
    { // Step 1
        bool available;//...available...
        uint balance; //...balance...
    }

    mapping (address => University) public universities; // address public universityName;//...universities... // Step 1 (state variable)
    // enum ProjectStatus { ... } // Step 2
    enum ProjectStatus {Waiting, Rejected, Approved, Disabled }

    // struct Project { // Step 2
    struct Project
    {
        address payable author;
        address payable university;
        ProjectStatus status;
        uint balance;
    }

    mapping (bytes32 => Project) public projects; // ...projects... // Step 2 (state variable)


    function registerUniversity(address payable _address)
    public
    onlyOwner
    {   // Step 1

        University storage university = universities[_address];
        university.available = true;
        university.balance = 0;
    }


    function disableUniversity(address payable _address)
    public
    onlyOwner
    { // Step 1
        University storage university = universities[_address];
        university.available = false;
    }


    // function submitProject... { // Step 2 and 4
    function submitProject (bytes32 hashDoc, address payable _university)
    public
    payable
    {
        uint _ether = 1 ether;
        University storage uni = universities[_university];
        require(msg.value == _ether && uni.available == true);
        projects[hashDoc] = Project(msg.sender, _university, ProjectStatus.Waiting, 0);
        ownerBalance += _ether;
    }


    // function disableProject... { // Step 3
    function disableProject (bytes32 hashDoc)
    public
    onlyOwner
    {
        projects[hashDoc].status = ProjectStatus.Disabled;
    }


    // function reviewProject... { // Step 3
    function reviewProject(bytes32 hashDoc, ProjectStatus _status)
    public
    onlyOwner
    {
        require(_status == ProjectStatus.Rejected || _status == ProjectStatus.Approved);
        require(projects[hashDoc].status == ProjectStatus.Waiting);
        projects[hashDoc].status = _status;
    }

    // function donate... { // Step 4
    function donate(bytes32 hashDoc)
    public
    payable
    {
        require(projects[hashDoc].status == ProjectStatus.Approved);
        projects[hashDoc].balance += msg.value / 100 * 70;
        University storage uni = universities[projects[hashDoc].university];
        uni.balance += msg.value / 100 * 20;
        ownerBalance += msg.value / 100 * 10;

    }
    // function withdraw... { // Step 5
    function withdraw()
    public
    payable
    {
        require(msg.sender == owner || universities[msg.sender].balance > 0);
        if(msg.sender == owner){
            msg.sender.transfer(ownerBalance);
            ownerBalance = 0;
        } else {
            msg.sender.transfer(universities[msg.sender].balance);
            universities[msg.sender].balance = 0;
        }
    }

    // function withdraw... {  // Step 5 (Overloading Function)
    function withdraw(bytes32 hashDoc)
    public
    payable
    {
        require(msg.sender == projects[hashDoc].author);
        uint bal = projects[hashDoc].balance;
        projects[hashDoc].balance = 0;
        msg.sender.transfer(bal);
    }
}