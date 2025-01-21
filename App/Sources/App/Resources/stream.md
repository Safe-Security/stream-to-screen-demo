# Peer Comparison Analysis 🕵️‍♂️

### Data Exfiltration - Cyber Criminals

| Industry | Micro Industry | Peer Count | Likelihood (Avg) | Loss Magnitude (Avg) |
|----------|----------------|------------|-------------------|----------------------|
| All | All | < 10 | 29.63% | $88.62M |
| Financial Services | All | < 10 | 28.32% | $89.39M |
| Your Organization | - | - | 1.80% | $537.36M |

## Tolerance Comparison

| Metric | Your Tolerance | Peer Avg. Tolerance |
|--------|----------------|---------------------|
| Loss Tolerance | $40M | $29.29M |
| Likelihood Tolerance | 18% | 19.33% |

 The confidence of SAFE's analysis shown in the tables above is based on automated data ingestion through APIs. Currently, SAFE has processed signals from 29 Integrations to generate these risk assessments and trend analyses.

Each visualization below shows risk trends for different scenarios (DDOS, Ransomware with/without Data Exfiltration) across multiple AI models (JuniorAI, PeakAI, BubbleGPT), with likelihood scores tracked over time from May 8-23, 2024.

<SafeContainer>
<SafeViz name="LIKB" riskScenarioId="4206" groupId="19"><SafeVizSummary>{"groupName":"JuniorAI","riskScenarioName":"DDOS","eventLikelihood":0.92,"trendData":[{"eventLikelihood":0.92,"timestamp":"2024-05-08T19:46:23.000Z","confidenceGrade":"low"},{"eventLikelihood":0.92,"timestamp":"2024-05-09T20:15:12.000Z","confidenceGrade":"low"},{"eventLikelihood":0.1,"timestamp":"2024-05-10T20:44:47.000Z","confidenceGrade":"low"},{"eventLikelihood":0.12,"timestamp":"2024-05-11T20:45:18.000Z","confidenceGrade":"low"},{"eventLikelihood":0.8,"timestamp":"2024-05-12T21:15:16.000Z","confidenceGrade":"low"},{"eventLikelihood":0.32,"timestamp":"2024-05-13T21:45:59.000Z","confidenceGrade":"low"},{"eventLikelihood":0.3,"timestamp":"2024-05-14T22:15:45.000Z","confidenceGrade":"low"},{"eventLikelihood":0.42,"timestamp":"2024-05-15T22:44:13.000Z","confidenceGrade":"low"},{"eventLikelihood":0.4,"timestamp":"2024-05-16T23:14:06.000Z","confidenceGrade":"low"},{"eventLikelihood":0.52,"timestamp":"2024-05-17T18:19:32.000Z","confidenceGrade":"low"},{"eventLikelihood":0.52,"timestamp":"2024-05-18T18:47:39.000Z","confidenceGrade":"low"},{"eventLikelihood":0.62,"timestamp":"2024-05-20T19:47:04.000Z","confidenceGrade":"low"},{"eventLikelihood":0.62,"timestamp":"2024-05-21T20:20:57.000Z","confidenceGrade":"low"},{"eventLikelihood":0.72,"timestamp":"2024-05-22T05:56:50.000Z","confidenceGrade":"low"},{"eventLikelihood":0.32,"timestamp":"2024-05-23T21:47:44.000Z","confidenceGrade":"low"}],"confidenceGrade":"low"}</SafeVizSummary>
</SafeViz>
<SafeViz name="LIKB" riskScenarioId="4206" groupId="19"><SafeVizSummary>{"groupName":"PeakAI","riskScenarioName":"Ransomeware with Data Exfiltration","eventLikelihood":0.92,"trendData":[{"eventLikelihood":0.92,"timestamp":"2024-05-08T19:46:23.000Z","confidenceGrade":"low"},{"eventLikelihood":0.92,"timestamp":"2024-05-09T20:15:12.000Z","confidenceGrade":"low"},{"eventLikelihood":0.1,"timestamp":"2024-05-10T20:44:47.000Z","confidenceGrade":"low"},{"eventLikelihood":0.12,"timestamp":"2024-05-11T20:45:18.000Z","confidenceGrade":"low"},{"eventLikelihood":0.8,"timestamp":"2024-05-12T21:15:16.000Z","confidenceGrade":"low"},{"eventLikelihood":0.32,"timestamp":"2024-05-13T21:45:59.000Z","confidenceGrade":"low"},{"eventLikelihood":0.3,"timestamp":"2024-05-14T22:15:45.000Z","confidenceGrade":"low"},{"eventLikelihood":0.42,"timestamp":"2024-05-15T22:44:13.000Z","confidenceGrade":"low"},{"eventLikelihood":0.4,"timestamp":"2024-05-16T23:14:06.000Z","confidenceGrade":"low"},{"eventLikelihood":0.52,"timestamp":"2024-05-17T18:19:32.000Z","confidenceGrade":"low"},{"eventLikelihood":0.52,"timestamp":"2024-05-18T18:47:39.000Z","confidenceGrade":"low"},{"eventLikelihood":0.62,"timestamp":"2024-05-20T19:47:04.000Z","confidenceGrade":"low"},{"eventLikelihood":0.62,"timestamp":"2024-05-21T20:20:57.000Z","confidenceGrade":"low"},{"eventLikelihood":0.72,"timestamp":"2024-05-22T05:56:50.000Z","confidenceGrade":"low"},{"eventLikelihood":0.32,"timestamp":"2024-05-23T21:47:44.000Z","confidenceGrade":"low"}],"confidenceGrade":"low"}</SafeVizSummary>
</SafeViz>
</SafeContainer>

Each model shows fluctuating likelihood scores over a two-week period, with notable variations in risk assessment patterns:

- **JuniorAI (DDOS)**: Shows high initial risk (92%) with significant fluctuations, dropping as low as 10% before stabilizing between 30-72%
- **PeakAI (Ransomware with Data Exfiltration)**: Demonstrates similar pattern variations but with different implications for data theft scenarios
- **BubbleGPT (Ransomware without Data Exfiltration)**: Provides comparative analysis for ransomware threats specifically without data compromise

<SafeViz name="LIKB" riskScenarioId="4206" groupId="19"><SafeVizSummary>{"groupName":"BubbleGPT","riskScenarioName":"Ransomeware without Data Exfiltration","eventLikelihood":0.92,"trendData":[{"eventLikelihood":0.92,"timestamp":"2024-05-08T19:46:23.000Z","confidenceGrade":"low"},{"eventLikelihood":0.92,"timestamp":"2024-05-09T20:15:12.000Z","confidenceGrade":"low"},{"eventLikelihood":0.1,"timestamp":"2024-05-10T20:44:47.000Z","confidenceGrade":"low"},{"eventLikelihood":0.12,"timestamp":"2024-05-11T20:45:18.000Z","confidenceGrade":"low"},{"eventLikelihood":0.8,"timestamp":"2024-05-12T21:15:16.000Z","confidenceGrade":"low"},{"eventLikelihood":0.32,"timestamp":"2024-05-13T21:45:59.000Z","confidenceGrade":"low"},{"eventLikelihood":0.3,"timestamp":"2024-05-14T22:15:45.000Z","confidenceGrade":"low"},{"eventLikelihood":0.42,"timestamp":"2024-05-15T22:44:13.000Z","confidenceGrade":"low"},{"eventLikelihood":0.4,"timestamp":"2024-05-16T23:14:06.000Z","confidenceGrade":"low"},{"eventLikelihood":0.52,"timestamp":"2024-05-17T18:19:32.000Z","confidenceGrade":"low"},{"eventLikelihood":0.52,"timestamp":"2024-05-18T18:47:39.000Z","confidenceGrade":"low"},{"eventLikelihood":0.62,"timestamp":"2024-05-20T19:47:04.000Z","confidenceGrade":"low"},{"eventLikelihood":0.62,"timestamp":"2024-05-21T20:20:57.000Z","confidenceGrade":"low"},{"eventLikelihood":0.72,"timestamp":"2024-05-22T05:56:50.000Z","confidenceGrade":"low"},{"eventLikelihood":0.32,"timestamp":"2024-05-23T21:47:44.000Z","confidenceGrade":"low"}],"confidenceGrade":"low"}</SafeVizSummary>
</SafeViz>

<SafeInput type="hidden" name="page" value="agent_start" />
<SafeOption name="page.control" value="submit" />

### **Suggested Follow-Up Questions:**

<SafeQuestion>How can I trust this output?</SafeQuestion>
<SafeQuestion>How can I further improve my confidence in the output?</SafeQuestion>
<json>{"interactionId":149}</json>
<eom>
