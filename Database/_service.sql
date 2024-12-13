-- Formative Assessment
SELECT COUNT(a.id), a.userid, u.loginid, u.firstname, MIN(a.finishscore) AS minscore, MAX(a.finishscore) AS maxscore
  FROM originpl_caige_oper.assessments a
  INNER JOIN originpl_caige_auth.users u ON u.userid = a.userid
  WHERE a.examid = '5c84f5f2-856c-482c-aba3-a2a70bacb6e3'
    AND a.userid NOT IN ('19800323-74e3-41de-a9f1-660928977797',
      '19830803-579c-4ef5-8a93-660890391258',
      '20240101-3064-422b-a1cc-660818789236',
      '62f9480e-66cc-4f0e-bbe7-41461f554fa6',
      'dde89c4d-fac5-457c-8e9e-47b36155b236',
      '36557ff3-f396-4bea-96fe-cc1f855beda7')
    AND a.finishminute > 0
  GROUP BY a.userid, u.loginid, u.firstname
  ORDER BY u.loginid;

-- examid
-- 1443a03a-6240-4f1a-8f5e-b651874a5aad
-- 5c84f5f2-856c-482c-aba3-a2a70bacb6e3
-- c32e1878-e474-4ecd-a82a-3cde08809008
-- 354dd615-fed1-451d-9a73-bb3a2a4edef4
-- 5d521c3c-cb52-4d56-8348-2f75c6af6196
-- f4013040-9e59-42a8-8644-412cf0f55c94
-- ce7ec279-c15b-4bbc-9207-a2906adf9e26
-- 9a8287ef-8016-4a7a-9600-9b1e11a6be7d
-- 9a3aa0d4-56be-4d51-80bf-ae8c0db8d31e
-- 730caacf-9a1b-4bb1-840d-b36df98c9799


-- Summative Assessment
SELECT COUNT(a.id), a.userid, u.loginid, u.firstname, MIN(a.finishscore) AS minscore, MAX(a.finishscore) AS maxscore
  FROM originpl_caige_oper.assessments a
  INNER JOIN originpl_caige_auth.users u ON u.userid = a.userid
  WHERE a.examid = '52356d42-14ac-4f00-92d8-41c4d06511c9'
    AND a.userid NOT IN ('19800323-74e3-41de-a9f1-660928977797',
      '19830803-579c-4ef5-8a93-660890391258',
      '20240101-3064-422b-a1cc-660818789236',
      '62f9480e-66cc-4f0e-bbe7-41461f554fa6',
      'dde89c4d-fac5-457c-8e9e-47b36155b236',
      '36557ff3-f396-4bea-96fe-cc1f855beda7')
    AND a.finishminute > 0
  GROUP BY a.userid, u.loginid, u.firstname
  ORDER BY u.loginid;