classdef Covid_Modeling_ODE < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        SusceptibleCheckBox             matlab.ui.control.CheckBox
        ExposedCheckBox                 matlab.ui.control.CheckBox
        InfectedCheckBox                matlab.ui.control.CheckBox
        RecoveredCheckBox               matlab.ui.control.CheckBox
        DeadCheckBox                    matlab.ui.control.CheckBox
        StatesofCovidLabel              matlab.ui.control.Label
        HowmanypeopleareinfectedEditFieldLabel  matlab.ui.control.Label
        HowmanypeopleareinfectedEditField  matlab.ui.control.NumericEditField
        HowmanypeoplerecoveredEditFieldLabel  matlab.ui.control.Label
        HowmanypeoplerecoveredEditField  matlab.ui.control.NumericEditField
        HowmanypeoplediedEditFieldLabel  matlab.ui.control.Label
        HowmanypeoplediedEditField      matlab.ui.control.NumericEditField
        WhatdayisittodayEditFieldLabel  matlab.ui.control.Label
        WhatdayisittodayEditField       matlab.ui.control.EditField
        mmddyyyyLabel                   matlab.ui.control.Label
        CalculateButton                 matlab.ui.control.Button
        HowmanydaysintothefutureEditFieldLabel  matlab.ui.control.Label
        HowmanydaysintothefutureEditField  matlab.ui.control.NumericEditField
        PleaserecalculateifnewnumbersareplacedLabel  matlab.ui.control.Label
        HowmanypeopleareexposedEditFieldLabel  matlab.ui.control.Label
        HowmanypeopleareexposedEditField  matlab.ui.control.NumericEditField
        ClearButton                     matlab.ui.control.Button
        ofPopulationLabel               matlab.ui.control.Label
        SocialDistancingLabel           matlab.ui.control.Label
        SocialDistancingLabel_2         matlab.ui.control.Label
        EditField                       matlab.ui.control.NumericEditField
    end


    properties (Access = private)
        N = '';
        Pre_infec = '';
        rate_pre_infec = '';
        Duration = '';
        Duration_rate = '';
        R0 = '';
        Beta = '';
        Death = 0;
        Death_Rate = 0;
        Numb_Cases = 0;
        Recovered = 0;
        Date = '01/01/2020';
        time = '';
        solution = '';
        Future = 2;
        sus;
        exposed;
        infec;
        recov;
        dead;
        Exposed = 0;
        Z = '';
        Percentage = 0;
        B = '';
    end

    methods (Access = private)
    
        function dydt = ode_SEIRD_Virginia_APP(app,t, y)
            S = y(1);
            E = y(2);
            I = y(3);

            dS = -app.B*I.*S;    
            dE = app.B*I.*S -  app.rate_pre_infec.*E;
            dI = app.rate_pre_infec*E - app.Duration_rate*I;
            dR = app.Duration_rate*(1-app.Death_Rate)*I;
            dD = (app.Death_Rate)*app.Duration_rate*I;

            dydt = [dS; dE; dI; dR; dD];
        end
        
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.N = 8626206;
            app.Pre_infec = 5.2;
            app.rate_pre_infec = 1/app.Pre_infec;
            app.Duration = 14;
            app.Duration_rate = 1/app.Duration;
            app.R0 = 2.5;
            app.Beta = app.R0/(app.N*app.Duration); % note that social dis lowers beta not sus because not a vaccine
            app.B = app.Beta;
        end

        % Value changed function: HowmanypeopleareinfectedEditField
        function HowmanypeopleareinfectedEditFieldValueChanged(app, event)
            app.Numb_Cases = app.HowmanypeopleareinfectedEditField.Value;
        end

        % Value changed function: HowmanypeoplediedEditField
        function HowmanypeoplediedEditFieldValueChanged(app, event)
            app.Death = app.HowmanypeoplediedEditField.Value;
            app.Death_Rate = app.Death/app.Numb_Cases;
        end

        % Value changed function: HowmanypeoplerecoveredEditField
        function HowmanypeoplerecoveredEditFieldValueChanged(app, event)
            app.Recovered = app.HowmanypeoplerecoveredEditField.Value;
            
        end

        % Value changed function: WhatdayisittodayEditField
        function WhatdayisittodayEditFieldValueChanged(app, event)
            app.Date = app.WhatdayisittodayEditField.Value;
            
        end

        % Value changed function: HowmanydaysintothefutureEditField
        function HowmanydaysintothefutureEditFieldValueChanged(app, event)
            app.Future = app.HowmanydaysintothefutureEditField.Value;
            
        end

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
          formatIn = 'mm/dd/yyyy';
          Q =datenum(app.Date,formatIn);
          app.Z = [Q:1:Q+app.Future]; 
          t_span = [0:1:app.Future];
          IC = [app.N-(app.Numb_Cases)-app.Death - app.Recovered-app.Exposed, app.Exposed, app.Numb_Cases, app.Recovered, app.Death];
          [app.time,app.solution] = ode45(@(t,y)ode_SEIRD_Virginia_APP(app,t,y),t_span,IC);
          cla(app.UIAxes)
          app.SusceptibleCheckBox.Value = 0;
          app.ExposedCheckBox.Value=0;
          app.InfectedCheckBox.Value=0;
          app.RecoveredCheckBox.Value=0;
          app.DeadCheckBox.Value = 0;
        end

        % Value changed function: SusceptibleCheckBox
        function SusceptibleCheckBoxValueChanged(app, event)
            value = app.SusceptibleCheckBox.Value;
            if app.Future <= 50;
                size = 5;
            else
                size = 2.5;
            end
            if value == 1;
               set(app.UIAxes, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
               app.sus = plot(app.UIAxes,app.Z,app.solution(:,1),'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',size);
               xlim(app.UIAxes,[min(app.Z) max(app.Z)])
               datetick(app.UIAxes,'x','mm/dd','keeplimits','keepticks')
               hold(app.UIAxes,'on')
            else
               delete(app.sus);
            end
        end

        % Value changed function: ExposedCheckBox
        function ExposedCheckBoxValueChanged(app, event)
            value = app.ExposedCheckBox.Value;
            if app.Future <= 50;
                size = 5;
            else
                size = 2.5;
            end
             if value == 1;
                set(app.UIAxes, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
                app.exposed = plot(app.UIAxes,app.Z,app.solution(:,2),'o','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',size);
                xlim(app.UIAxes,[min(app.Z) max(app.Z)])
                datetick(app.UIAxes,'x','mm/dd','keeplimits','keepticks')
                hold(app.UIAxes,'on');
            else
               delete(app.exposed)
            end
        end

        % Value changed function: InfectedCheckBox
        function InfectedCheckBoxValueChanged(app, event)
            value = app.InfectedCheckBox.Value;
            if app.Future <= 50;
                size = 5;
            else
                size = 2.5;
            end
             if value == 1;
                set(app.UIAxes, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
                app.infec = plot(app.UIAxes,app.Z,app.solution(:,3),'o','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',size);
                xlim(app.UIAxes,[min(app.Z) max(app.Z)])
                datetick(app.UIAxes,'x','mm/dd','keeplimits','keepticks')
                hold(app.UIAxes,'on')
            else
                delete(app.infec)
            end
        end

        % Value changed function: RecoveredCheckBox
        function RecoveredCheckBoxValueChanged(app, event)
            value = app.RecoveredCheckBox.Value;
            if app.Future <= 50;
                size = 5;
            else
                size = 2.5;
            end
             if value == 1;
                set(app.UIAxes, 'XTickMode', 'auto', 'XTickLabelMode', 'auto') 
                app.recov=plot(app.UIAxes,app.Z,app.solution(:,4),'o','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize',size);
                xlim(app.UIAxes,[min(app.Z) max(app.Z)])
                datetick(app.UIAxes,'x','mm/dd','keeplimits','keepticks')
                hold(app.UIAxes,'on')
                
            else
                delete(app.recov)
            end
        end

        % Value changed function: DeadCheckBox
        function DeadCheckBoxValueChanged(app, event)
            value = app.DeadCheckBox.Value;
            if app.Future <= 50;
                size = 5;
            else
                size = 2.5;
            end
             if value == 1;
                set(app.UIAxes, 'XTickMode', 'auto', 'XTickLabelMode', 'auto') 
                app.dead=plot(app.UIAxes,app.Z,app.solution(:,5),'o','MarkerFaceColor','black','MarkerEdgeColor','black','MarkerSize',size);
                xlim(app.UIAxes,[min(app.Z) max(app.Z)])
                datetick(app.UIAxes,'x','mm/dd','keeplimits','keepticks')
                hold(app.UIAxes,'on')
            else
                delete(app.dead)
            end
        end

        % Value changed function: HowmanypeopleareexposedEditField
        function HowmanypeopleareexposedEditFieldValueChanged(app, event)
            app.Exposed = app.HowmanypeopleareexposedEditField.Value;
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
          cla(app.UIAxes)
          app.SusceptibleCheckBox.Value = 0;
          app.ExposedCheckBox.Value=0;
          app.InfectedCheckBox.Value=0;
          app.RecoveredCheckBox.Value=0;
          app.DeadCheckBox.Value = 0;
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            app.Percentage = app.EditField.Value;
            Factor = (-1/100) * app.Percentage + 1;
            app.B = app.Beta * Factor;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.Resize = 'off';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Progression of COVID VA (N = 8,626,206)')
            xlabel(app.UIAxes, 'Time (Days)')
            ylabel(app.UIAxes, 'Population of VA')
            app.UIAxes.PlotBoxAspectRatio = [1.55947955390335 1 1];
            app.UIAxes.Position = [40 197 386 273];

            % Create SusceptibleCheckBox
            app.SusceptibleCheckBox = uicheckbox(app.UIFigure);
            app.SusceptibleCheckBox.ValueChangedFcn = createCallbackFcn(app, @SusceptibleCheckBoxValueChanged, true);
            app.SusceptibleCheckBox.Text = 'Susceptible';
            app.SusceptibleCheckBox.FontWeight = 'bold';
            app.SusceptibleCheckBox.FontColor = [1 0 0];
            app.SusceptibleCheckBox.Position = [475 394 89 22];

            % Create ExposedCheckBox
            app.ExposedCheckBox = uicheckbox(app.UIFigure);
            app.ExposedCheckBox.ValueChangedFcn = createCallbackFcn(app, @ExposedCheckBoxValueChanged, true);
            app.ExposedCheckBox.Text = 'Exposed';
            app.ExposedCheckBox.FontWeight = 'bold';
            app.ExposedCheckBox.FontColor = [0.4706 0.6706 0.1882];
            app.ExposedCheckBox.Position = [475 374 72 22];

            % Create InfectedCheckBox
            app.InfectedCheckBox = uicheckbox(app.UIFigure);
            app.InfectedCheckBox.ValueChangedFcn = createCallbackFcn(app, @InfectedCheckBoxValueChanged, true);
            app.InfectedCheckBox.Text = 'Infected';
            app.InfectedCheckBox.FontWeight = 'bold';
            app.InfectedCheckBox.FontColor = [0 0 1];
            app.InfectedCheckBox.Position = [475 354 68 22];

            % Create RecoveredCheckBox
            app.RecoveredCheckBox = uicheckbox(app.UIFigure);
            app.RecoveredCheckBox.ValueChangedFcn = createCallbackFcn(app, @RecoveredCheckBoxValueChanged, true);
            app.RecoveredCheckBox.Text = 'Recovered';
            app.RecoveredCheckBox.FontWeight = 'bold';
            app.RecoveredCheckBox.FontColor = [1 0 1];
            app.RecoveredCheckBox.Position = [475 334 83 22];

            % Create DeadCheckBox
            app.DeadCheckBox = uicheckbox(app.UIFigure);
            app.DeadCheckBox.ValueChangedFcn = createCallbackFcn(app, @DeadCheckBoxValueChanged, true);
            app.DeadCheckBox.Text = 'Dead';
            app.DeadCheckBox.FontWeight = 'bold';
            app.DeadCheckBox.Position = [475 314 51 22];

            % Create StatesofCovidLabel
            app.StatesofCovidLabel = uilabel(app.UIFigure);
            app.StatesofCovidLabel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.StatesofCovidLabel.FontSize = 14;
            app.StatesofCovidLabel.FontWeight = 'bold';
            app.StatesofCovidLabel.Position = [468 418 107 22];
            app.StatesofCovidLabel.Text = 'States of Covid';

            % Create HowmanypeopleareinfectedEditFieldLabel
            app.HowmanypeopleareinfectedEditFieldLabel = uilabel(app.UIFigure);
            app.HowmanypeopleareinfectedEditFieldLabel.HorizontalAlignment = 'right';
            app.HowmanypeopleareinfectedEditFieldLabel.Position = [31 147 174 22];
            app.HowmanypeopleareinfectedEditFieldLabel.Text = 'How many people are infected?';

            % Create HowmanypeopleareinfectedEditField
            app.HowmanypeopleareinfectedEditField = uieditfield(app.UIFigure, 'numeric');
            app.HowmanypeopleareinfectedEditField.Limits = [0 8626206];
            app.HowmanypeopleareinfectedEditField.ValueChangedFcn = createCallbackFcn(app, @HowmanypeopleareinfectedEditFieldValueChanged, true);
            app.HowmanypeopleareinfectedEditField.Position = [211 147 100 22];

            % Create HowmanypeoplerecoveredEditFieldLabel
            app.HowmanypeoplerecoveredEditFieldLabel = uilabel(app.UIFigure);
            app.HowmanypeoplerecoveredEditFieldLabel.HorizontalAlignment = 'right';
            app.HowmanypeoplerecoveredEditFieldLabel.Position = [31 82 165 22];
            app.HowmanypeoplerecoveredEditFieldLabel.Text = 'How many people recovered?';

            % Create HowmanypeoplerecoveredEditField
            app.HowmanypeoplerecoveredEditField = uieditfield(app.UIFigure, 'numeric');
            app.HowmanypeoplerecoveredEditField.Limits = [0 8626206];
            app.HowmanypeoplerecoveredEditField.ValueChangedFcn = createCallbackFcn(app, @HowmanypeoplerecoveredEditFieldValueChanged, true);
            app.HowmanypeoplerecoveredEditField.Position = [211 82 100 22];

            % Create HowmanypeoplediedEditFieldLabel
            app.HowmanypeoplediedEditFieldLabel = uilabel(app.UIFigure);
            app.HowmanypeoplediedEditFieldLabel.HorizontalAlignment = 'right';
            app.HowmanypeoplediedEditFieldLabel.Position = [31 115 134 22];
            app.HowmanypeoplediedEditFieldLabel.Text = 'How many people died?';

            % Create HowmanypeoplediedEditField
            app.HowmanypeoplediedEditField = uieditfield(app.UIFigure, 'numeric');
            app.HowmanypeoplediedEditField.Limits = [0 8626206];
            app.HowmanypeoplediedEditField.ValueChangedFcn = createCallbackFcn(app, @HowmanypeoplediedEditFieldValueChanged, true);
            app.HowmanypeoplediedEditField.Position = [211 115 100 22];

            % Create WhatdayisittodayEditFieldLabel
            app.WhatdayisittodayEditFieldLabel = uilabel(app.UIFigure);
            app.WhatdayisittodayEditFieldLabel.HorizontalAlignment = 'right';
            app.WhatdayisittodayEditFieldLabel.Position = [355 141 117 22];
            app.WhatdayisittodayEditFieldLabel.Text = 'What day is it today?';

            % Create WhatdayisittodayEditField
            app.WhatdayisittodayEditField = uieditfield(app.UIFigure, 'text');
            app.WhatdayisittodayEditField.ValueChangedFcn = createCallbackFcn(app, @WhatdayisittodayEditFieldValueChanged, true);
            app.WhatdayisittodayEditField.Position = [487 141 100 22];
            app.WhatdayisittodayEditField.Value = '01/01/2020';

            % Create mmddyyyyLabel
            app.mmddyyyyLabel = uilabel(app.UIFigure);
            app.mmddyyyyLabel.Position = [380 120 77 22];
            app.mmddyyyyLabel.Text = '(mm/dd/yyyy)';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.UIFigure, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [425 59 119 42];
            app.CalculateButton.Text = 'Calculate';

            % Create HowmanydaysintothefutureEditFieldLabel
            app.HowmanydaysintothefutureEditFieldLabel = uilabel(app.UIFigure);
            app.HowmanydaysintothefutureEditFieldLabel.HorizontalAlignment = 'right';
            app.HowmanydaysintothefutureEditFieldLabel.Position = [31 18 174 22];
            app.HowmanydaysintothefutureEditFieldLabel.Text = 'How many days into the future?';

            % Create HowmanydaysintothefutureEditField
            app.HowmanydaysintothefutureEditField = uieditfield(app.UIFigure, 'numeric');
            app.HowmanydaysintothefutureEditField.Limits = [2 Inf];
            app.HowmanydaysintothefutureEditField.ValueChangedFcn = createCallbackFcn(app, @HowmanydaysintothefutureEditFieldValueChanged, true);
            app.HowmanydaysintothefutureEditField.Position = [211 18 100 22];
            app.HowmanydaysintothefutureEditField.Value = 2;

            % Create PleaserecalculateifnewnumbersareplacedLabel
            app.PleaserecalculateifnewnumbersareplacedLabel = uilabel(app.UIFigure);
            app.PleaserecalculateifnewnumbersareplacedLabel.FontWeight = 'bold';
            app.PleaserecalculateifnewnumbersareplacedLabel.FontAngle = 'italic';
            app.PleaserecalculateifnewnumbersareplacedLabel.Position = [355 28 270 22];
            app.PleaserecalculateifnewnumbersareplacedLabel.Text = 'Please re-calculate if new numbers are placed';

            % Create HowmanypeopleareexposedEditFieldLabel
            app.HowmanypeopleareexposedEditFieldLabel = uilabel(app.UIFigure);
            app.HowmanypeopleareexposedEditFieldLabel.HorizontalAlignment = 'right';
            app.HowmanypeopleareexposedEditFieldLabel.Position = [31 51 171 22];
            app.HowmanypeopleareexposedEditFieldLabel.Text = 'How many people are exposed';

            % Create HowmanypeopleareexposedEditField
            app.HowmanypeopleareexposedEditField = uieditfield(app.UIFigure, 'numeric');
            app.HowmanypeopleareexposedEditField.ValueChangedFcn = createCallbackFcn(app, @HowmanypeopleareexposedEditFieldValueChanged, true);
            app.HowmanypeopleareexposedEditField.Position = [211 51 100 22];

            % Create ClearButton
            app.ClearButton = uibutton(app.UIFigure, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.FontSize = 14;
            app.ClearButton.FontWeight = 'bold';
            app.ClearButton.FontColor = [0.4902 0.1804 0.5608];
            app.ClearButton.Position = [570 346 51 38];
            app.ClearButton.Text = 'Clear';

            % Create ofPopulationLabel
            app.ofPopulationLabel = uilabel(app.UIFigure);
            app.ofPopulationLabel.Position = [436 243 89 32];
            app.ofPopulationLabel.Text = '% of Population';

            % Create SocialDistancingLabel
            app.SocialDistancingLabel = uilabel(app.UIFigure);
            app.SocialDistancingLabel.Position = [435 232 97 22];
            app.SocialDistancingLabel.Text = 'Social Distancing';

            % Create SocialDistancingLabel_2
            app.SocialDistancingLabel_2 = uilabel(app.UIFigure);
            app.SocialDistancingLabel_2.FontSize = 14;
            app.SocialDistancingLabel_2.FontWeight = 'bold';
            app.SocialDistancingLabel_2.Position = [459 274 122 22];
            app.SocialDistancingLabel_2.Text = 'Social Distancing';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'numeric');
            app.EditField.Limits = [0 100];
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [531 240 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Covid_Modeling_ODE

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end