import React, { Component } from "react";
import axios from 'axios';
import MetaturfHorseRacingDataContract from "./contracts/MetaturfHorseRacingData.json";
import MetaturfNFTContract from "./contracts/MetaturfNFT.json";
import getWeb3 from "./getWeb3";
import "./App.css";
import { MintForm } from "./components/mintForm.js";
import { ImportHorseForm } from "./components/importHorseForm.js";
import { ImportCSVHorseForm } from "./components/importCSVHorseForm.js";
import { ViewHorseList } from "./components/viewHorseList.js";
import { ViewTokenList } from "./components/viewTokenList.js";

class App extends Component {

  state = {
    web3: null,
    accounts: null,
    metaturfHorseRacingDataInstance: null,
    metaturfNFTInstance: null,
    daysofraces: [],
    races: '',
    numberoftokens: 0,
    horsetokenid: 0,
    state_message: ''
  };

  componentDidMount = async () => {

     try {

      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the network.
      const networkId = await web3.eth.net.getId();
      const metaturfHorseRacingDataDeployedNetwork = MetaturfHorseRacingDataContract.networks[networkId];
      const metaturfNFTDeployedNetwork = MetaturfNFTContract.networks[networkId];

      // Get the contract instances.
      const MetaturfHorseRacingDataInstance = new web3.eth.Contract(
        MetaturfHorseRacingDataContract.abi,
        metaturfHorseRacingDataDeployedNetwork && metaturfHorseRacingDataDeployedNetwork.address,
      );
      const MetaturfNFTInstance = new web3.eth.Contract(
        MetaturfNFTContract.abi,
        metaturfNFTDeployedNetwork && metaturfNFTDeployedNetwork.address,
      );

      console.log('MetaturfHorseRacingData: ' + metaturfHorseRacingDataDeployedNetwork.address);
      console.log('MetaturfNFT: ' + metaturfNFTDeployedNetwork.address);

      // Set web3, accounts, and contracts to the state
      this.setState({ web3, 
                      accounts, 
                      metaturfHorseRacingDataInstance: MetaturfHorseRacingDataInstance,
                      metaturfNFTInstance: MetaturfNFTInstance
                    }, this.getInitialData);

    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  // componentDidUpdate() {
  //   if ((this.state.accounts != undefined && this.state.web3.eth.accounts[0] != undefined) && (this.state.web3.eth.accounts[0] !== this.state.accounts[0])) {
  //     alert(this.state.accounts[0] + "####" + this.state.web3.eth.accounts[0]);
  //     //this.setState({ accounts: this.state.web3.eth.accounts });
  //     //window.location.reload();
  //   }
  // }

  getInitialData = async () => {
    const { metaturfNFTInstance } = this.state;
    this.getLastRaces();
    const data = await metaturfNFTInstance.methods.getNumberOfTokens().call();
    this.setState({ numberoftokens: data });
  };

  getLastRaces = async () => {

    /*
    {"code":1,
     "status":200,
     "data":
      {"rows":[
        {"racesdate":"20210905","racecourseid":"3","racecourse":"Lasarte","racesdate_verbose":"05 Septiembre"},
        {"racesdate":"20210829","racecourseid":"3","racecourse":"Lasarte","racesdate_verbose":"29 Agosto"},
        {"racesdate":"20210828","racecourseid":"15","racecourse":"La S\u00e9nia","racesdate_verbose":"28 Agosto"},
        {"racesdate":"20210826","racecourseid":"1","racecourse":"La Zarzuela","racesdate_verbose":"26 Agosto"}]}}
    */
    try {
      axios.get(`https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=lastresults&id=14&format=json`).then(res => {
        const daysofraces = res.data.data.rows;
        this.setState({ daysofraces });
      
        //console.log(JSON.stringify({ daysofraces}, null, 2));
        //console.log(res.data.data.rows.length);
    
        let i=0, race_request, racesdate, racecourseid, lastraces = "";
    
        for (i = 0; i < res.data.data.rows.length; i++) {
          try {
            //console.log(res.data.data.rows[i]["racecourse"] + "-" + res.data.data.rows[i]["racecourseid"] + 
            //                                  "-" + res.data.data.rows[i]["racesdate"]);
                
            racesdate = res.data.data.rows[i]["racesdate"];
            racecourseid = res.data.data.rows[i]["racecourseid"];
    
            race_request = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=listraces&id=" +
                           racecourseid + "&date=" + racesdate + "&format=json";
    
           /* {"code":1,"status":200,"data":"7178,7182,7179,7183,7184,7180,7181"} */
    
           axios.get(race_request).then(res_race => {
              lastraces += res_race.data.data + ",";
              //console.log(lastraces);
              this.setState({ races: lastraces });
              //console.log(JSON.stringify({ races }, null, 2));
            })

          } catch (error) {
            alert(`Failed to load races.`);
            console.error(error);
          }
        }
        /* {"code":1,"status":200,"data":{"horseinfo":"13882,GALILODGE (FR),1"}} */
      })
    } catch (error) {
      alert(`Failed to load days of races info from Metaturf API.`);
      console.error(error);
    }
  }

  setHorse = async () => {
    try {

      const { metaturfHorseRacingDataInstance, accounts } = this.state;
      await metaturfHorseRacingDataInstance.methods.setHorseFromCSV("12,GALILODGE (FR),1").send({ from: accounts[0] });
    } catch (error) {
      alert(
        `setHorse failed. Check console for details.`,
      );
      console.error(error);
    }
  }

  horsesAvailable = async () => {
    const { metaturfHorseRacingDataContract } = this.state;
    metaturfHorseRacingDataContract.methods.mint(739,this.state.accounts[0]);
  }

  setStateMessage = (_state_message) => {
    this.setState({state_message: _state_message})
  }

  render() {    

    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }

    return (
      <div className="App">

        <div align="right">Your account is: {this.state.accounts[0]}</div><br></br>

        <h1>Spanish Horseracing data and NFTs</h1>
        
        <div className="statemessage">{this.state.state_message}</div>

        <h2>Metaturf REST API</h2>

        <h3>Last days of races in Spain: {this.state.daysofraces.length}</h3>
        <ul className="list">
          {this.state.daysofraces.map(date => <li>{date.racesdate} {date.racecourse} {date.racesdate_verbose}</li>)}
        </ul>

        <h3>Last races available to fecth winners:</h3>
        <div>{this.state.races}</div>

        <br/><h2>Horses on-chain</h2>

        <h3>Import horse on-chain using Chainlink oracle (choose Race ID from above)</h3>
        <div><ImportHorseForm metaturfHorseRacingDataInstance={this.state.metaturfHorseRacingDataInstance}
                  account={this.state.accounts[0]}
                  setStateMessage = {this.setStateMessage}/></div>

        <h3>Import horse on-chain (only for testing, should be done always through Chainlink oracle)</h3>
        <div><ImportCSVHorseForm metaturfHorseRacingDataInstance={this.state.metaturfHorseRacingDataInstance}
                  account={this.state.accounts[0]}
                  setStateMessage = {this.setStateMessage}/></div>

        <br/><h3>Horses imported</h3>
        <ViewHorseList metaturfHorseRacingDataInstance={this.state.metaturfHorseRacingDataInstance} />

        <br/><h2>NFTs</h2>
        
        <h3>Mint</h3> 
        {/* <div><button onClick={this.mint}>Mint</button></div> */}
        {/* <div><button onClick={this.sayHello}>Default</button></div> */}

        <div><MintForm metaturfNFTInstance={this.state.metaturfNFTInstance}
                  account={this.state.accounts[0]} setStateMessage = {this.setStateMessage}/></div>

        <br/><h3>Tokens minted: {this.state.numberoftokens}</h3>

        {<ViewTokenList metaturfNFTInstance={this.state.metaturfNFTInstance} setStateMessage = {this.setStateMessage}/>}

        {/* <ViewNFT metaturfNFTInstance={this.state.metaturfNFTInstance} tokenid="1"/> */} 
        {/* <ViewNFT metaturfNFTInstance={this.state.metaturfNFTInstance} tokenid="2"/> */}

      </div>

    );
  }
}

export default App;
