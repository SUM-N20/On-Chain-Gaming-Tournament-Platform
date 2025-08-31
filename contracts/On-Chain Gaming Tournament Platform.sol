// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title On-Chain Gaming Tournament Platform
/// @notice This contract allows players to register for tournaments,
///         track participation, and reward winners on-chain.
contract Project {
    address public owner;
    uint256 public tournamentIdCounter;

    struct Tournament {
        uint256 id;
        string name;
        uint256 entryFee;
        address[] participants;
        address winner;
        bool ended;
    }

    mapping(uint256 => Tournament) public tournaments;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        tournamentIdCounter = 1;
    }

    /// @notice Create a new tournament
    /// @param _name The tournament name
    /// @param _entryFee Entry fee in wei
    function createTournament(string memory _name, uint256 _entryFee) external onlyOwner {
        Tournament storage t = tournaments[tournamentIdCounter];
        t.id = tournamentIdCounter;
        t.name = _name;
        t.entryFee = _entryFee;
        tournamentIdCounter++;
    }

    /// @notice Register a player for a tournament
    /// @param _tournamentId Tournament ID
    function register(uint256 _tournamentId) external payable {
        Tournament storage t = tournaments[_tournamentId];
        require(!t.ended, "Tournament has ended");
        require(msg.value == t.entryFee, "Incorrect entry fee");
        t.participants.push(msg.sender);
    }

    /// @notice Declare the winner of a tournament and transfer reward
    /// @param _tournamentId Tournament ID
    /// @param _winner Address of the winner
    function declareWinner(uint256 _tournamentId, address _winner) external onlyOwner {
        Tournament storage t = tournaments[_tournamentId];
        require(!t.ended, "Tournament already ended");

        uint256 prizePool = t.entryFee * t.participants.length;
        t.winner = _winner;
        t.ended = true;

        payable(_winner).transfer(prizePool);
    }
}

