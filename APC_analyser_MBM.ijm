/*Madison Bolger-Munro, Gold Lab, Department of Microbiology and Immunology, University of British Columbia
 * If using, please cite: 
 * https://elifesciences.org/articles/44574
 * 
 * FIJI Macro for cropping and analyzing B cell immune synapses.
 * Can be added to the tool bar with an icon that says APC if you copy and paste into your startup macro file /FIJI/macros/StartupMacros.ijm
 *
 */


//tool bar icon
macro "APC analyzer Action Tool - C000C111C222C333D33D40D43D51D53D64D86D87D88D89D8aD95D99DacDb7Dd9DdfC333D32D85D8bC333C444D50DabDadDb6Db8DbaDbeC444C555D25D52D63D65Dc9DcfC555C666D41Da5C666C777D34Da9DefC777C888D24D31C888C999D62Da6Da8DaeDb9DbfDe9C999CaaaD75CaaaD30DbbDbdCaaaCbbbD23D35D42DaaCbbbCcccD76D77D78D79D7aDa7DbcDeaCcccCdddD54D7bDb5DcaCdddCeeeD61D74CeeeCfffDceCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D26D27D28D29D2aD2bD2cD2dD2eD2fD36D37D38D39D3aD3bD3cD3dD3eD3fD44D45D46D47D48D49D4aD4bD4cD4dD4eD4fD55D56D57D58D59D5aD5bD5cD5dD5eD5fD60D66D67D68D69D6aD6bD6cD6dD6eD6fD70D71D72D73D7cD7dD7eD7fD80D81D82D83D84D8cD8dD8eD8fD90D91D92D93D94D96D97D98D9aD9bD9cD9dD9eD9fDa0Da1Da2Da3Da4DafDb0Db1Db2Db3Db4Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8DcbDccDcdDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8DdaDdbDdcDddDdeDe0De1De2De3De4De5De6De7De8DebDecDedDeeDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDff"{

	

// GUI




  SquareSize=50;
  Dialog.create("APC Analyzer!");
  Dialog.addMessage("Welcome to the great APC analyzer macro!\nPlease cite Bolger-Munro et al., 2019\nhttps://elifesciences.org/articles/44574")
  
  Dialog.addCheckbox("Use previously saved settings?", false);

  Dialog.addNumber("Square dimensions (pixels):", 50);
  Dialog.addString("Ag end", "C2.tif");
  Dialog.addString("Sig end", "C0.tif");
  Dialog.addString("Rolling ball radius (background subtraction)", "10");
  Dialog.addNumber("Minimum particle size limit:", 0.01);
  threshold = newArray("Default", "Otsu", "Triangle", "Huang");
  Dialog.addChoice("Theshold", threshold, "Otsu");


  
  
  
  Dialog.show();
	check= Dialog.getCheckbox();
	SquareSize= Dialog.getNumber();
	AgEnd= Dialog.getString();
	SigEnd= Dialog.getString();
	Ball= Dialog.getString();
	MinSize= Dialog.getNumber();
	mask= Dialog.getChoice();
	
		
	



//file making

inputDir = getDirectory("choose the input directory"); 
listdir = getFileList( inputDir ); 

if (check==true) {
			run("Text File... ", "open="+inputDir+"User_parameters.txt");
			selectWindow("User_parameters.txt");
		string1= getInfo();
		string_val= split(string1, "\n");

	SquareSize1= split(string_val[0],":");
	SquareSize= SquareSize1[1];
	name_end_ag= split(string_val[1],":");
	AgEnd= name_end_ag[1];
	name_end_sig= split(string_val[2],":");
	SigEnd= name_end_sig[1];
	Ball1= split(string_val[3],":");
	Ball= Ball1[1];
	MinSize1= split(string_val[4],":");
	MinSize= MinSize1[1];
	mask1= split(string_val[5],":");
	mask= mask1[1];
	}
	else { user_pram = "[User Parameters]";
  run("New... ", "name="+user_pram+" type=Table");
  tt = user_pram;
  print(tt, "Crop box dimensions (pixels):" + SquareSize);
  print(tt, "Antigen channel ID:" + AgEnd);
  print(tt, "Signalling channel ID:" + SigEnd);
  print(tt, "Rolling ball radius (pixels):" +Ball);
  print(tt, "Minimum size of particle (pixels):" +MinSize);
  print(tt, "Theshold method:" +mask);
selectWindow("User Parameters");
              saveAs("Text", inputDir + "User_parameters.txt");
              run("Close");
	}


for (i = 0; i < listdir.length; i++) { 
        path = inputDir + listdir[i]; 
        if ( File.isDirectory(  path  )  ) { 
            
out_dir= path + "/output/";
File.makeDirectory(out_dir);
ag_dir= out_dir + "/Ag/";
File.makeDirectory(ag_dir);
sig_dir = out_dir + "/sig/";
File.makeDirectory(sig_dir);
roi_dir = out_dir + "/ROI/";
File.makeDirectory(roi_dir);

        }



			  
              
              final();
              

              
        } 
} 





//---run---//

//final();




///fuctions below///
function final(){	
opener();
selectWindow("Ag");
doit();
}



function doit(){

	



y=nSlices;
    	for (i = 0; i < y; i++) { //for every image in a stack do this:
    		saveName=i; //set the saving name to the slice number
			RectangleOn_MouseClick(); //runs the clicker function
			run("Next Slice [>]");
			selectWindow("Ag");
			IJ.redirectErrorMessages();
			
			}
			

cropsave();
}

function cropsave(){
cropAll();  //runs the croping function 
roiManager("reset"); // clear ROI manager for next image 
selectWindow("Ag"); //reselect correct chanel
saverAg(); // runs this function (analyzes and saves Ag)
saverSig(); // runs this function (analyzes and saves Sig)
run("Close All");
close("Results");
roiManager("reset");



}

function opener(){ //opens the images to work with into a stack of all
run("Image Sequence...", "open=&path file=&AgEnd sort");
rename("Ag");
run("Image Sequence...", "open=&path file=&SigEnd sort");
rename("Sig");

}



function RectangleOn_MouseClick(){ 

        setOption("DisablePopupMenu", true); 
        getPixelSize(unit, pixelWidth, pixelHeight); 
        setTool("rectangle"); 
        leftButton=16; 
        rightButton=4; 
        height = SquareSize; 
        width = SquareSize; 
        x2=-1; y2=-1; z2=-1; flags2=-1; 
        getCursorLoc(x, y, z, flags); 
        wasLeftPressed = false; 
        while (flags&rightButton==0){ 
                getCursorLoc(x, y, z, flags); 
                if (flags&leftButton!=0) { 
                // Wait for it to be released 
                wasLeftPressed = true; 
                } 
                else if (wasLeftPressed) { 
                wasLeftPressed = false; 
                
                if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) { 
                                x = x - width/2; 
                                y = y - height/2; 
                                makeRectangle(x, y, width, height); 
                                roiManager("Add"); 
                                IJ.redirectErrorMessages();
                                  
                        } 
                 
                 }
                
      } 
    } 




function cropAll(){ //crops the cells in the roi manager and runs the saving functions 
	selectWindow("Ag");
	dupSaveAg();
	selectWindow("Sig");
	dupSaveSignal();
	roiManager("Save", roi_dir + saveName + ".zip"); //saves ROIs
	

}





//The actual cropping functions 
function dupSaveSignal(){
	n = roiManager("count"); // gets number of rois saved in roi manager
	for (i = 0; i<  n; i++) { 
		roi_n= i;
		roiManager("Select", roi_n);
		//duplicates each roi and renames 
		run("Duplicate...", "title="+saveName+"-"+roi_n+1+"");
		name= getTitle; 
	// be sure to save in the correct location
		save(sig_dir + "Sig-" + name + ".tif");
	// closes the first image stack
		roiManager("Deselect");
		close();
	}

}

// does same for the antigen channel 

function dupSaveAg(){
	n = roiManager("count"); // gets number of rois saved in roi manager
	for (i= 0; i<  n; i++) { 
	roi_n= i;
	roiManager("Select", roi_n);
	run("Duplicate...", "title="+saveName+"-"+roi_n+1+"");
	name= getTitle ;
	save(ag_dir + "Ag-" + name + ".tif");
	roiManager("Deselect");
	close();
	
	
}

}

function saverAg(){ //opens all the croped Ag cells into a stack and runs the analysis on them
	run("Image Sequence...", "open=&ag_dir sort");
	save(out_dir + "Ag.tif");
	name = getTitle();
	rename("Ag-backsub");
	name_ag= getTitle();
	output = getDirectory("image"); //get directory of open image for saving
	selectImage("Ag-backsub");
	run("Subtract Background...", "rolling=&Ball disable stack"); //rolling ball radius set to 2
	save(output + name + "backsub.tif"); //save background subtracted image
	selectImage("Ag-backsub");
	run("Duplicate...", "title=test duplicate");
	run("Convert to Mask", "method=&mask background=Dark calculate");
	save(output + name + "mask.tif"); //save thresholded binary
	run("Set Measurements...", "area mean min centroid center integrated stack display redirect=&name_ag decimal=3");
	run("Analyze Particles...", " size=" +MinSize+ "-Infinity display add stack");  //size is 0.1-infinity uM
	roiManager("Save", output + name + ".zip"); //saves ROIs
	roiManager("reset");
	saveAs("Results", out_dir + name + "Results.csv"); //save results
	close("Results");
	run("Close All");
	
}

function saverSig(){ //opens all the croped Sig cells into a stack and runs the analysis on them
	
	run("Image Sequence...", "open=&sig_dir sort");
	save(out_dir + "Sig.tif");
	name = getTitle();
	rename("Sig-backsub");
	name_sg= getTitle();
	output = getDirectory("image"); //get directory of open image for saving
	selectImage("Sig-backsub");
	run("Subtract Background...", "rolling=&Ball disable stack"); //rolling ball radius set to 2
	save(output + name + "backsub.tif"); //save background subtracted image
	selectImage("Sig-backsub");
	run("Duplicate...", "title=test duplicate");
	run("Convert to Mask", "method=&mask background=Dark calculate");
	save(output + name + "mask.tif"); //save thresholded binary
	run("Set Measurements...", "area mean min centroid center integrated stack display redirect=&name_sg decimal=3");
	run("Analyze Particles...", "display add stack");  //size is 0.1-infinity uM
	roiManager("Save", output + name + ".zip"); //saves ROIs
	roiManager("reset");
	saveAs("Results", out_dir + name + "Results.csv"); //save results
	close("Results");
	run("Close All");
}


}