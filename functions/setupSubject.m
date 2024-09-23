function Experiment = setupSubject(Experiment)
% Set Up Subject
mainPath = Experiment.Paths.MainPath;

%% Request participant information
switch Experiment.Mode.mode
    case 'test'
        session = 1;
        set = 1;
        run = 1;
        age = '21';
        sex = 'female';
        
        ok = [];
        while ~strcmp(ok,'y')
            fprintf(['\nSession: ' num2str(session)]);
            fprintf(['\nSet: ' num2str(set)]);
            fprintf(['\nRun: ' num2str(run)]);
            fprintf(['\nAge: ' age]);
            fprintf(['\nSex: ' sex]);
            ok = input('\nContinue? Y/N.  ','s'); ok = lower(ok);
        end
    case 'experiment'
        ok = [];
        while ~strcmp(ok,'y')
            session = input('Session:  ');
            set = input('Set:  ');
            run = input('Run:  ');
            age = input('Age:  ');
            sex = input('Sex:  ','s');

            ok = input('\nContinue? Y/N.  ','s'); ok = lower(ok);
        end
end

Experiment.Subject.WhichSession = session;
Experiment.Subject.WhichSet = set;
Experiment.Subject.WhichRun = run;
Experiment.Subject.Age = age;
Experiment.Subject.Sex = sex;