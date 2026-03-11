import "@typespec/http";
import "@microsoft/typespec-m365-copilot";

using TypeSpec.Http;
using TypeSpec.M365.Copilot.Actions;

@service
@actions(#{
    nameForHuman: "GitHub Project Management API",
    descriptionForModel: "GitHub API integration for project management including issue tracking, pull request management, and project insights",
    descriptionForHuman: "Use this API to manage GitHub repositories, track issues, and coordinate development projects"
})
@server("https://api.github.com", "GitHub API")
@useAuth(OAuth2Auth<[{
  type: OAuth2FlowType.authorizationCode,
  authorizationUrl: "https://github.com/login/oauth/authorize",
  tokenUrl: "https://github.com/login/oauth/access_token",
  scopes: ["repo", "issues", "pull_requests", "project"]
}]>)
namespace GitHubAuthAPI {
  // Issue Management
  /** Create a new issue in a GitHub repository. */
  @route("/repos/{owner}/{repo}/issues")
  @post
  op createIssue(
    @path owner: string,
    @path repo: string,
    @body issue: IssueCreateRequest
  ): IssueResponse | NotFoundResponse | UnauthorizedResponse | ValidationErrorResponse;

  /** List issues in a GitHub repository with optional filters. */
  @route("/repos/{owner}/{repo}/issues")
  @get
  op getIssues(
    @path owner: string,
    @path repo: string,
    @query state?: "open" | "closed" | "all",
    @query labels?: string,
    @query assignee?: string,
    @query milestone?: string,
    @query since?: string
  ): IssueListResponse | NotFoundResponse | UnauthorizedResponse;

  /** Update an existing issue in a GitHub repository. */
  @route("/repos/{owner}/{repo}/issues/{issue_number}")
  @patch
  op updateIssue(
    @path owner: string,
    @path repo: string,
    @path issue_number: int32,
    @body update: IssueUpdateRequest
  ): IssueResponse | NotFoundResponse | UnauthorizedResponse | ValidationErrorResponse;

  // Pull Request Management
  /** List pull requests in a GitHub repository. */
  @route("/repos/{owner}/{repo}/pulls")
  @get
  op getPullRequests(
    @path owner: string,
    @path repo: string,
    @query state?: "open" | "closed" | "all",
    @query head?: string,
    @query base?: string,
    @query sort?: "created" | "updated" | "popularity"
  ): PullRequestListResponse | NotFoundResponse | UnauthorizedResponse;

  /** Create a new pull request in a GitHub repository. */
  @route("/repos/{owner}/{repo}/pulls")
  @post
  op createPullRequest(
    @path owner: string,
    @path repo: string,
    @body pr: PullRequestCreateRequest
  ): PullRequestResponse | NotFoundResponse | UnauthorizedResponse | ValidationErrorResponse;

  /** Merge a pull request in a GitHub repository. */
  @route("/repos/{owner}/{repo}/pulls/{pull_number}/merge")
  @put
  op mergePullRequest(
    @path owner: string,
    @path repo: string,
    @path pull_number: int32
  ): MergeResponse | NotFoundResponse | UnauthorizedResponse | ConflictResponse;

  // Project Insights
  /** Get contributor statistics and project insights for a GitHub repository. */
  @route("/repos/{owner}/{repo}/stats/contributors")
  @get
  op getProjectInsights(
    @path owner: string,
    @path repo: string
  ): ProjectInsightsResponse | NotFoundResponse | UnauthorizedResponse;

  // Request/Response Models
  model IssueCreateRequest {
    title: string;
    body?: string;
    assignees?: string[];
    milestone?: int32;
    labels?: string[];
  }

  model IssueUpdateRequest {
    title?: string;
    body?: string;
    state?: "open" | "closed";
    assignees?: string[];
    milestone?: int32;
    labels?: string[];
  }

  model IssueResponse {
    id: int32;
    number: int32;
    title: string;
    body?: string;
    state: "open" | "closed";
    assignees: User[];
    milestone?: Milestone;
    labels: Label[];
    created_at: string;
    updated_at: string;
    closed_at?: string;
    html_url: string;
  }

  model IssueListResponse {
    issues: IssueResponse[];
    total_count: int32;
  }

  model PullRequestResponse {
    id: int32;
    number: int32;
    title: string;
    body?: string;
    state: "open" | "closed";
    head: BranchInfo;
    base: BranchInfo;
    user: User;
    assignees: User[];
    reviewers: User[];
    created_at: string;
    updated_at: string;
    merged_at?: string;
    html_url: string;
    draft: boolean;
  }

  model PullRequestListResponse {
    pull_requests: PullRequestResponse[];
    total_count: int32;
  }

  model ProjectInsightsResponse {
    total_commits: int32;
    contributors: ContributorStats[];
    top_languages: LanguageStats[];
    recent_activity: ActivitySummary;
  }

  model User {
    id: int32;
    login: string;
    avatar_url: string;
    html_url: string;
  }

  model Milestone {
    id: int32;
    number: int32;
    title: string;
    description?: string;
    state: "open" | "closed";
    due_on?: string;
  }

  model Label {
    id: int32;
    name: string;
    description?: string;
    color: string;
  }

  model BranchInfo {
    label: string;
    ref: string;
    sha: string;
    repo: RepositoryInfo;
  }

  model RepositoryInfo {
    id: int32;
    name: string;
    full_name: string;
    owner: User;
    html_url: string;
  }

  model ContributorStats {
    author: User;
    total_commits: int32;
    weeks: WeeklyStats[];
  }

  model WeeklyStats {
    week: string;
    additions: int32;
    deletions: int32;
    commits: int32;
  }

  model LanguageStats {
    language: string;
    bytes: int32;
    percentage: float64;
  }

  model ActivitySummary {
    commits_last_week: int32;
    issues_opened: int32;
    issues_closed: int32;
    pull_requests_opened: int32;
    pull_requests_merged: int32;
  }

  model PullRequestCreateRequest {
    title: string;
    head: string;
    base: string;
    body?: string;
  }

  model MergeResponse {
    sha: string;
    merged: boolean;
    message: string;
  }

  // Error Response Models
  @error
  model NotFoundResponse {
    @statusCode statusCode: 404;
    message: string;
    documentation_url?: string;
  }

  @error
  model UnauthorizedResponse {
    @statusCode statusCode: 401;
    message: string;
    documentation_url?: string;
  }

  @error
  model ValidationErrorResponse {
    @statusCode statusCode: 422;
    message: string;
    errors?: ValidationError[];
    documentation_url?: string;
  }

  model ValidationError {
    resource: string;
    field: string;
    code: string;
  }

  @error
  model ConflictResponse {
    @statusCode statusCode: 409;
    message: string;
    documentation_url?: string;
  }
}