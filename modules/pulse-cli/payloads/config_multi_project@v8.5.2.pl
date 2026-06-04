export interface PulseConfig {
  org: string;
  projectNumber: number;
  repoName?: string;
  oracleRepos: Record<string, string>;
  routing?: RoutingConfig;
  peers?: PulsePeer[];
  labels?: {
    oracleColor?: string;
    p0Color?: string;
  };
  protocolVersion?: string;
  gateway?: { repo: string; oracle: string };
  orchestrator?: { repo: string; oracle: string };
  board?: { 
    ITB: string | { repo: string; projectNumber: number };
    AIB: string | { repo: string; projectNumber: number };
  };
  patchWorkspace?: string;
  blog?: {
    repo?: string;
    category?: string;
  };
}