import { useState, useEffect } from "react";
import { ethers } from "ethers";
import "./App.css";
import { CONTRACT_ABI, CONTRACT_ADDRESS } from "./constants/index.js";

function App() {
  const [account, setAccount] = useState("");
  const [fstring, setFstring] = useState("");
  const [wordlist, setWordlist] = useState([]);
  const [targetString, setTargetString] = useState("");
  let contract;
  const connectMetamask = async (event) => {
    event.preventDefault();
    if (typeof window.ethereum !== "undefined") {
      try {
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        setAccount(accounts[0]);
      } catch (error) {
        console.error(error);
      }
    }
  };

  const connectContract = async (event) => {
    
  };
  const generateNumber = async (event) => {
    event.preventDefault();
    try {
      //console.log(contract.address);
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      //  console.log("hello")
      const signer = provider.getSigner();
      contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
      console.log(contract.address);
      const gno = await contract.generateRandomNumber();
      await gno.wait();
      const randomno = await contract.randomNumber();
      console.log("Random no: ", randomno);
    } catch (error) {
      console.error(error);
    }
  };
  const participate = async (event) => {
    event.preventDefault();
    try {
        
        const provider = new ethers.providers.Web3Provider(window.ethereum);
      //  console.log("hello")
        const signer = provider.getSigner();
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
        console.log(contract.address);
        const participationTx = await contract.participate();
        await participationTx.wait();

    // Get the updated value from the contract after the participation
    const isParticipating = await contract.isPlayerParticipating(account);
    console.log("Is participating:", isParticipating);
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    console.log(targetString);
  }, [targetString]);

  return (
    <div className="App">
      <div className="desktop-1">
      <div className="word-break-parent">
      <form className="f1">
      <p className="head">Odd Even Bets</p>
      {account ==="" ? (
      <p></p>
): account !=="" ?(
      <p className="account">Hello: {account}</p>
      ): null}
      
      <br />
        <label className="label">Bets:</label>
        <input type="input" className="input1" placeholder="string" value={fstring} onChange={(e) => setFstring(e.target.value)} />
        
        
        <br />
        <br />
        <button className="connect" onClick={connectMetamask}>
          Connect Metamask
        </button>
        <button className="participate" onClick={participate}>
          Participate
        </button>
        <br></br>
        <button className="GNo" onClick={generateNumber}>
          Generate Number
        </button>
        
        <button className="button" onClick={connectContract}>
          Place Bets
        </button>
      </form>
      
      <br />
      {targetString.toString() === "true" ? (
  <p className="ts">The targetString can made from wordList</p>
) : targetString.toString() === "false" ? (
  <p className="ts">The targetString cannot be made from wordList</p>
) : targetString.toString() === "" ? (
  <p className="ts"></p>
) : null}

    </div>
    </div>
    </div>
  );
}

export default App;
