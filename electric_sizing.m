% input parameters
%payload = input('Enter the mass of the payload incuding the crew (kg): ');
payload = 150;
%Mbatt = input('Enter mass of the battery (kg): ');
Mbatt = 72;
%V = input('Enter the velocity (m/s): ');
V = 60;
V = V*3.6;
%h = input('Enter max altitude of trip (ft): ');
h = 10000;
h = h / 3280;
%p_used = input('Enter power used to climb (usually the max power permitted by motor) (kW): ');
p_used = 57;
%p_cruise = input('Enter power used to cruise (kW): ');
p_cruise = 50;
%Esb = input('Enter battery specific energy (wh/kg): ');
Esb = 750;
%eta = input('Enter propeller efficienty: ');
eta = .8;
%eta2 = input('Enter system efficienty of battery and motor: ');
eta2 = .9;
%liftdrag = input('Enter the lift to drag ratio: ');
liftdrag = 14;
%numparabola = input('How many times will the experience zero-g? ');
numparabola = 10;
%numLoiter = input("How many times will the aircraft loiter? ");
numLoiter = 0;
%for i = 1:numLoiter
    %timeLoiter(i) = input(sprintf("How long will the aircraft loiter for loiter number %d (hours): ",i));               % ask user how long the aircraft will loiter for corresponding the each loiter section in the mission       
%end

%initGuess = input('Enter the initial guess for the gross weight (kg): ');
initGuess = 2000;


g = 9.81;
a = 1;
while a
   
    range = liftdrag * ((Esb * eta2 *eta)/g) * ((2*Mbatt)/initGuess);                   % calculate range of electric aircraft based on constants and guess of gross weight used to calculate the cruise battery mass fraction
    endurance = 3.6 * liftdrag * ((Esb * eta2 *eta)/(g*V)) * ((2*Mbatt)/initGuess);     % calculate the endurance of the electric aircraft used for calculating the loitering battery mass fraction
    %Cruise = (range * g) / (3.6 * Esb * eta2 * eta * liftdrag);                             % cruise ratio calculation for electric aircraft
    Cruise = ((1000 * .006111 * p_cruise) / (Esb * eta2 * initGuess)) * numparabola;
   
   
                                                                % calculate loiter ratio for each loitering segment for electric aircraft
    Loiter = (endurance * V * g) / (3.6 * Esb * eta2 * eta * liftdrag);
    loiterTotal = numLoiter * Loiter;
    
    Vv = ((1000 * eta * p_used) / (g * initGuess)) - (V / (3.6 * (liftdrag*.866)));
    climb = ((h * p_used) / (3.6 * Vv * Esb * eta2 * initGuess)) * numparabola;
    %climb = ((1000 * .005555 * p_used) / (Esb * eta2 * initGuess)) * numparabola;
   
   
    mission = climb + loiterTotal + Cruise;                                            % calculate total mission ratio
    Wempty = 2.36 * (initGuess^-.18);                                                 % calculate Wempty/Wgross ratio. change coefficients for different aircraft and or variable sweep constant (constants found in Raymer for types of aircraft)
   
    Wgross = (payload)/ (1 - mission - Wempty)                                       % calculate new gross ratio determined by the previous guess (could be initial guess or previous iteration)
    error = 0.005 * Wgross;

    if (initGuess >= (Wgross - error)) & (initGuess <= (Wgross + error))             % determine if previous guess is within error range of new calcuation
        a = 0;
    else
       initGuess = Wgross;
    end 
end


fprintf("The gross mass of the aircraft is %.0f kg\n",initGuess);