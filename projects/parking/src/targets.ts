interface Target {
  readonly base: `https://${string}`;
  readonly includePath?: boolean;
  readonly includeSearch?: boolean;
  readonly includeHash?: boolean;
}

interface Targets {
  readonly default: Target;
  readonly [key: string]: Target;
}

export const targets: Targets = {
  default: { base: 'https://github.com/Shakeskeyboarde' },
};
