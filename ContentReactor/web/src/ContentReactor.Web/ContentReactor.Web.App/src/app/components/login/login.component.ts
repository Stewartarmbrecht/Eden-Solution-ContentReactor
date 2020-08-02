import { OnInit, Component, Input } from '@angular/core';
import { HubConnection } from '@aspnet/signalr';
import { Router } from '@angular/router';
import { DataService } from '../../services/data.service';
import { HubService } from '../../services/hub.service';
import { AppInsightsService } from '../../services/app-insights.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  title = 'app';
  name = '';
  userid = '';
  reconnect: Function;

  ngOnInit() {}

  constructor(
    private router: Router,
    private data: DataService,
    private hub: HubService,
    private appInsightsService: AppInsightsService
  ) {}

  public connectToHub(): void {
    this.hub.createConnection(environment.apiUrl, this.userid);

    this.hub
      .getHubConnection()
      .start()
      .then(() => {
        console.log('Connection started successfully');
        this.data.setCurrentUser(this.userid);
        this.appInsightsService.logEvent(
          'SignalR Connection Established',
          this.userid
        );
        this.router.navigateByUrl('home');
      })
      .catch(err => console.log('Error while establishing connection'));
  }
}
