import { useState } from 'react';
import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export function AnimationDebugPanel() {
  const { data, act } = useBackend<AnimationDebugPanelData>();
  const [selectedChain, setSelectedChain] = useState<number>(1);

  return (
    <Window title="Animation Debug Panel">
      <Stack>
        <Stack.Item>
          <ArgumentSection selected_chain={selectedChain} />
        </Stack.Item>
      </Stack>
    </Window>
  );
}

function get_chain_at(index: number): AnimateChain | undefined {
  const { data } = useBackend<AnimationDebugPanelData>();
  const chain = data.chain;
  return undefined;
}

function ArgumentSection(props: { selected_chain: number }) {
  const { data, act } = useBackend<AnimationDebugPanelData>();
  const { animate_arguments } = data;
  const chain = get_chain_at(props.selected_chain);
  return <Section title="Arguments">{typeof data.animate_arguments}</Section>;
}
