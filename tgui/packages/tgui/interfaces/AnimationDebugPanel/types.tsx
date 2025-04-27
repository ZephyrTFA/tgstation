type AnimationDebugPanelData = {
  target: string;
  chain: AnimateChain;
  animate_arguments: AnimateArgumentData;
  animate_easing_flags: AnimateEasingFlagData;
  animate_easings: AnimateEasingData;
  animate_flags: AnimateFlagData;
};

type AnimateChain = {
  next: AnimateChain | undefined;
  chain_index: number;
  time: number;
  loop: number;
  easing: number | undefined;
  easing_flags: number | undefined;
  flags: number | undefined;
  delay: number | undefined;
  a_tag: string | undefined;
  command: string | undefined;
};

type AnimateEasingData = Record<
  string,
  {
    description: string;
    value: number;
  }
>;

type AnimateFlagData = Record<
  string,
  {
    description: string;
    value: number;
  }
>;

type AnimateEasingFlagData = Record<
  string,
  {
    description: string;
    value: number;
  }
>;

type AnimateArgumentData = {
  name: string;
  description: string;
  valid_types: string[];
};
