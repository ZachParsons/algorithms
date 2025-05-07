const shortestCommonSupersequence = require('../../lib/shortest_common_supersequence/dp');

describe('ShortestCommonSupersequence', () => {
  const testCases = [
    {
      description: 'Jealous/Jewel case',
      input: ['Jealous', 'Jewel'],
      validOutputs: ['Jeawelous', 'Jewealous', 'Jewaelous'],
    },
    {
      description: 'Park/Polka case',
      input: ['Park', 'Polka'],
      validOutputs: ['Parolka', 'Polarka', 'Poalrka'],
    },
    {
      description: 'Binary pattern case',
      input: ['bbbaaaba', 'bbababbb'],
      validOutputs: ['bbbaaababbb'],
    },
  ];

  testCases.forEach(({ description, input, validOutputs }) => {
    test(`${description}`, () => {
      const [str1, str2] = input;
      const result = shortestCommonSupersequence(str1, str2);
      expect(validOutputs).toContain(result);
    });
  });

  test('handles empty strings', () => {
    expect(shortestCommonSupersequence('', '')).toBe('');
    expect(shortestCommonSupersequence('abc', '')).toBe('abc');
    expect(shortestCommonSupersequence('', 'def')).toBe('def');
  });
});
