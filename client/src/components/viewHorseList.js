import React from "react";
//import ReactHtmlParser from "react-html-parser";

export class ViewHorseList extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      horse_data_array: []
    };
    this.listHorses();
  }

  async listHorses () {
    try {

      const horses = await this.props.metaturfHorseRacingDataInstance.methods.listHorses().call();
      
      //console.log(horses);
      
      for (var i = 0; i < horses.length ; i++) {
        const horsedata = await this.props.metaturfHorseRacingDataInstance.methods.getHorse(horses[i]).call();
        
        const horsetext = "(" + horses[i] + ") Name: " + horsedata[0] + ', Wins: ' + horsedata[1]
        this.setState({horse_data_array: this.state.horse_data_array.concat(horsetext)});

        //console.log(horsedata[0] + ' ' + horsedata[1]);
        //console.log(this.state.horse_data_array);
      }
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `listHorses failed. Check console for details.`,
      );
      console.error(error);
    }
  }

  render() {

    return (
      <div>
        <ul className="list" >
          {this.state.horse_data_array.map(item => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      </div>
    );
  }
}
