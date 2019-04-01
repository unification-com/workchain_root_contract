pragma solidity ^0.5.0;

contract WRKChainRootSlim {
    //ID of the wrkchain, as defined in genesis.json
    //Cannot be modified once written
    uint64 public chain_id;

    //hash of full genesis block
    //Cannot be modified once written
    bytes32 public genesis_hash;

    //Current EVs - also used to whitelist addresses that can write to contract
    mapping(address => bool) current_evs;
    address[] current_evs_idx;

    //Modifier to ensure only current EVs can execute a function
    modifier onlyEv() {
        require(current_evs[msg.sender] == true);
        _;
    }

    //Contract constructor. Sets Chain ID, Genesis, and initial EVs
    constructor(
        uint64 _chain_id,
        bytes32 _genesis_hash,
        address[] memory _evs
    )
        public
    {

        require(_chain_id > 0, "ChainID required");
        require(_genesis_hash.length > 0, "Genesis block required");
        require(_evs.length > 0, "Initial EVs required");
        chain_id = _chain_id;
        genesis_hash = _genesis_hash;

        for (uint i=0; i<_evs.length; i++) {
            current_evs[_evs[i]] = true;
        }
        current_evs_idx = _evs;

    }

    //Record a wrkchain block header
    function recordHeader(
        uint64 _height,
        bytes32 _hash,
        bytes32 _parent_hash,
        bytes32 _receipt_root,
        bytes32 _tx_root,
        bytes32 _state_root,
        address _sealer,
        uint64 _chain_id) public onlyEv {

        require(_chain_id == chain_id, "Chain ID does not match");

    }

    //Set the new EVs
    function setEvs(address[] memory _new_evs) public onlyEv {
        require(_new_evs.length > 0, "EVs required");

        for(uint i =0; i < current_evs_idx.length; i++) {
            current_evs[current_evs_idx[i]] = false;
        }

        for (uint i=0; i<_new_evs.length; i++) {
            current_evs[_new_evs[i]] = true;
        }

        delete current_evs_idx;
        current_evs_idx = _new_evs;
    }


    //get the Genesis block
    function getGenesis() public view returns (bytes32 genesis_hash_) {
        genesis_hash_ = genesis_hash;
    }

    //get the Chain ID
    function getChainId() public view returns (uint64 chain_id_) {
        chain_id_ = chain_id;
    }

    //return list of current EVs
    function getEvs() public view returns (address[] memory current_evs_idx_) {
        current_evs_idx_ = current_evs_idx;
    }

    //Check if public address is an EV
    function isEv(address _ev) public view returns (bool) {
        if(current_evs[_ev] == true) {
            return true;
        }
        return false;
    }
}
