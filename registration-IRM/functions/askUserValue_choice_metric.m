function [tmin, tmax, tstep, rmin, rmax, rstep, metric] = askUserValue_choice_metric()
    fprintf('\n');
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
    
    fprintf('\n');
    disp(['Choose the metric (enter 1 for Squared difference and 2 for Mutual information)']);
    
    prompt = 'metric : ';
    metric = input(prompt);

end