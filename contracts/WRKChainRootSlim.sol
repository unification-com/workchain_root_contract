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
    
    //Slim header
    struct BlockHeader {
        uint64 height;
        bytes32 hash;
        address sealer;
    }
    // Store the hashes
    mapping(uint64 => BlockHeader) block_headers;
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
        uint64 _chain_id) external onlyEv {

        require(_chain_id == chain_id, "Chain ID does not match");
        require(current_evs[msg.sender] == true, "Sealer is not a current EV");
        block_headers[_height] = BlockHeader(
            _height,
            _hash,
            msg.sender
        );
    }
    
    // get header at some height
    function getHeader(uint64 _height) external view returns (
        bytes32 hash,
        address sealer) {
        BlockHeader storage bh = block_headers[_height];

        hash = bh.hash;
        sealer = bh.sealer;
    } 
   
    //Set the new EVs
    function setEvs(address[] calldata _new_evs) external onlyEv {
        require(_new_evs.length > 0, "EVs required");

        for(uint i =0; i < current_evs_idx.length; i++) {
            current_evs[current_evs_idx[i]] = false;
        }

        for (uint i=0; i<_new_evs.length; i++) {
            current_evs[_new_evs[i]] = true;
        }

        current_evs_idx = _new_evs;
    }


    //get the Genesis block
    function getGenesis() external view returns (bytes32 genesis_hash_) {
        genesis_hash_ = genesis_hash;
    }

    //get the Chain ID
    function getChainId() external view returns (uint64 chain_id_) {
        chain_id_ = chain_id;
    }

    //return list of current EVs
    function getEvs() external view returns (address[] memory current_evs_idx_) {
        current_evs_idx_ = current_evs_idx;
    }

    //Check if public address is an EV
    function isEv(address _ev) external view returns (bool) {
    	   return current_evs[_ev];
    }
}
