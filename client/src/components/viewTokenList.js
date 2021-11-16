import React from "react";
import { ViewNFT } from "./viewNFT.js";

export class ViewTokenList extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      token_data_array: []
    };
    this.listTokens();
  }

  async listTokens () {
    try {
      const tokens = await this.props.metaturfNFTInstance.methods.listTokens().call();
      
      //console.log(tokens);
      this.setState({token_data_array: tokens});

      // for (var i = 0; i < listTokens.length ; i++) {
      //   const horsedata = await this.props.metaturfHorseRacingDataInstance.methods.getHorse(horses[i]).call();
        
      //   const horsetext = "(" + horses[i] + ") Name: " + horsedata[0] + ', Wins: ' + horsedata[1]
      //   this.setState({token_data_array: this.state.token_data_array.concat(horsetext)});

      //   //console.log(horsedata[0] + ' ' + horsedata[1]);
      //   console.log(this.state.token_data_array);
      // }
    } catch (error) {
      alert(`listTokens failed. Check console for details.`);
      console.error(error);
    }
  }

  render() {
    return (
      <div>
        <ul >
          {this.state.token_data_array.map(item => (
            <ViewNFT metaturfNFTInstance={this.props.metaturfNFTInstance} tokenid={item}/>
          ))}
        </ul>
      </div>
    );
  }
}
