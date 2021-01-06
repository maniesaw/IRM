function [tmin, tmax, tstep, rmin, rmax, rstep] = askUserValue()
    disp(['Enter the values of lower/upper bounds and steps for translation and rotation']);

    prompt = 'tmin : ';
    tmin = input(prompt);

    prompt = 'tmax : ';
    tmax = input(prompt);

    prompt = 'tstep : ';
    tstep = input(prompt);

    prompt = 'rmin : ';
    rmin = input(prompt);

    prompt = 'rmax : ';
    rmax = input(prompt);

    prompt = 'rstep : ';
    rstep = input(prompt);

end