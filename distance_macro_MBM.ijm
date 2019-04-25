/*Madison Bolger-Munro, Gold Lab, Department of Microbiology and Immunology, University of British Columbia
 * FIJI Macro for measuring distance from microcluster to Ag center of mass
 * NOTE: change pixel scale size on line 32 for your microscope 
 * NOTE: takes binary videos in a folder. Saves all info to an output folder called "com_distance" in the input directory
 */
inputDir = getDirectory("choose the input directory"); // select folder with input files
listdir = getFileList( inputDir ); 
out_dir= inputDir + "/com_distance/"; //make new folder to store output files 
File.makeDirectory(out_dir);


for (z = 0; z < listdir.length; z++) {
	  	path = inputDir + listdir[z];  // for all the files in the folder, if it ends with tif, open 
	  	if (endsWith(path,".tif")==1) {
	 	open(path);
	 	run("Remove Overlay"); //remove and overlay or selections that might be there
	 	run("Select None");
		n_ext= getTitle; 
		ext = indexOf(n_ext, "."); 
		name= substring(n_ext, 0, ext); //gets name without extension 
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //set scale to pixels 
		run("Set Measurements...", "area mean min centroid center shape integrated stack display redirect=None decimal=3"); //set measurements 
		delete(); //run funtion delete to remove any images with no fluorescence (careful if you have some in the middle for some reason..) (see below)
		saveAs(out_dir + name); //save file 
		run("Analyze Particles...", "size=1.10-Infinity exclude add stack"); //analyze particles of entire movie, adding the particle rois to the roi manager 
		n=roiManager("count"); //count the number of particles detected
		s1= newArray(); //make array to store stuff in 
		combine(); // this function combines all the ag particles into one roi to find the center of mass.
		del_roi(n); // this funtion leaves just the ag combines rois in the roi manager
		
		x1= newArray(); //make new array for x coordinates
		y1= newArray(); //make new array y coordinates 
		get_centers(); //run get centers function (see below)
		run("Set Scale...", "distance=6.25 known=1 unit=um global"); //set scale back to um **Make sure to change this for your pixel size!
		roiManager("measure"); //measure the rois (lines)
		selectWindow("Results"); // save results
		saveAs("Results", out_dir + name + "distances.csv"); 
		roiManager("Save", out_dir + name + "distancelines.zip"); 	 //save lines
		
		run("Close All"); //close everything and reset to do next file)
		close("Results");
		roiManager("reset");
		}
}


function delete(){ //deletes slices where there is no fluorescence (these happen at the start of my movies, be careful if you for some reason have some in the middle!)
id= getImageID();
Stack.getDimensions(width,height,channels,slices,frames);

s = 1;
while (s <= slices) {
setSlice(s);
getRawStatistics(nPixels, mean, min, max, std, histogram);
if (mean == 255) {
	run("Delete Slice");
	s = s - 1;
	Stack.getDimensions(width,height,channels,newSlices,frames);
	slices = newSlices;
    }
s++;
}
}


function combine() { // this function makes a combined selection for the Ag particles to find the center of the Ag fluorescence

for (i = 0; i < nSlices; i++) {
	test= i + 1;
	s1= newArray(); //array to store the particles in 
	
	for (p = 0; p < n; p++) {
		roiManager("select", p);
		name= Roi.getName();
		char= substring(name,2,4);
		int_char= parseInt(char);
		ch_new= int_char +1; //select rois from the same frame and add them to the array
		if (int_char == test){
			s1= Array.concat(s1,p);
			
		}
		
		}
		
		if (s1.length > 1){
			Array.print(s1);
			roiManager("select", s1);
			roiManager("combine"); //combines all the Ag rois from one slice into one roi and saves to the roi manager
			roiManager("add");
		}
		else {
			roiManager("select", s1); //if only one Ag particle, adds this roi to manager
			roiManager("add");
		}
	}
}

function del_roi(n) { //removes the individual particle rois and leaves just the new ones made in combine()
	a1=newArray();
	for (t = 0; t < n; t++) {
		a1= Array.concat(a1,t);
		}
		roiManager("select", a1);
		roiManager("delete");
}

function get_centers() { //gets the center of mass of Ag for each frame. 
count=roiManager("count");
roiManager("measure"); //measures the combined rois
roiManager("Save", out_dir + name + "cellcenters.zip");  //saves them to the output folder 
for (m = 0; m < count; m++) {
roiManager("select", m) //for each line in the Results window, save the x and y coordinates of the center of mass into the x and y arrays
x= getResult("X", m);
x1= Array.concat(x1,x);
y= getResult("Y", m);
y1= Array.concat(y1,y);

}
 x1 = Array.slice(x1,1);
 y1 = Array.slice(y1,1);
 Array.print(x1);
setSlice(1);
run("Select None");
roiManager("reset");
selectWindow("Results");		
run("Close");
for (a=0; a<nSlices; a++){ 
	
	x_1=x1[a];
	y_1=y1[a];
	run("Analyze Particles...", "size=1.1-Infinity display exclude "); //get the ceneters for all the particles but dont save in roi manager
	num=nResults;
	for (p = 0; p < num; p++) { //for each particle detected, get center of mass
			x_s= getResult("X", p); 
			y_s= getResult("Y", p);
			makeLine(x_1, y_1, x_s, y_s); //make line from center of particel to the center of mass of all ag particles 
			roiManager("add"); //add this line to the roi manager 		
			}
	run("Next Slice [>]"); //do for all the slices in the video 
	selectWindow("Results");		
	run("Close");
	roiManager("deselect");
}

}
	
	
	

