import "@typespec/http";
import "@microsoft/typespec-m365-copilot";

using TypeSpec.Http;
using TypeSpec.M365.Copilot.Actions;

@service
@actions(#{
  nameForHuman: "Microsoft Graph (My Profile)",
  descriptionForModel: "Microsoft Graph API for retrieving the signed-in user's profile, calendar events, and recent emails using SSO. No separate login is required.",
  descriptionForHuman: "Access your Microsoft 365 profile, calendar, and emails seamlessly via SSO."
})
@server("https://graph.microsoft.com/v1.0", "Microsoft Graph API")
@useAuth(MicrosoftGraphSSO)
namespace MicrosoftGraphAPI {

  /** OAuth2 SSO for Microsoft Graph */
  model MicrosoftGraphSSO is OAuth2Auth<[{
    type: OAuth2FlowType.authorizationCode,
    authorizationUrl: "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize",
    tokenUrl: "https://login.microsoftonline.com/organizations/oauth2/v2.0/token",
    scopes: ["https://graph.microsoft.com/User.Read", "https://graph.microsoft.com/Calendars.Read", "https://graph.microsoft.com/Mail.Read"]
  }]>;

  // --- Models ---

  model UserProfile {
    displayName?: string;
    givenName?: string;
    surname?: string;
    mail?: string;
    jobTitle?: string;
    officeLocation?: string;
    mobilePhone?: string;
    department?: string;
    userPrincipalName?: string;
    id?: string;
  }

  model CalendarEvent {
    id?: string;
    subject?: string;
    @doc("Start time of the event")
    start?: DateTimeInfo;
    @doc("End time of the event")
    end?: DateTimeInfo;
    @doc("Location of the event")
    location?: Location;
    isAllDay?: boolean;
    organizer?: Organizer;
  }

  model DateTimeInfo {
    dateTime?: string;
    timeZone?: string;
  }

  model Location {
    displayName?: string;
  }

  model Organizer {
    emailAddress?: EmailAddress;
  }

  model EmailAddress {
    name?: string;
    address?: string;
  }

  model EmailMessage {
    id?: string;
    subject?: string;
    from?: EmailSender;
    receivedDateTime?: string;
    bodyPreview?: string;
    isRead?: boolean;
  }

  model EmailSender {
    emailAddress?: EmailAddress;
  }

  model CalendarEventList {
    value: CalendarEvent[];
  }

  model EmailMessageList {
    value: EmailMessage[];
  }

  // --- Operations ---

  /** Get the signed-in user's profile. Returns display name, email, job title, department, and other profile information. */
  @route("/me")
  @get
  op getMyProfile(): UserProfile;

  /** Get the signed-in user's upcoming calendar events within a time range. */
  @route("/me/calendarView")
  @get
  op getMyCalendarEvents(
    @query startDateTime: string,
    @query endDateTime: string,
    @query("$top") top?: int32 = 10,
    @query("$orderby") orderby?: string = "start/dateTime"
  ): CalendarEventList;

  /** Get the signed-in user's recent emails. */
  @route("/me/messages")
  @get
  op getMyEmails(
    @query("$top") top?: int32 = 10,
    @query("$orderby") orderby?: string = "receivedDateTime desc",
    @query("$select") select?: string = "subject,from,receivedDateTime,bodyPreview,isRead"
  ): EmailMessageList;
}
