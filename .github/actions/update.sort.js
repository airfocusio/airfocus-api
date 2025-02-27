const inputStr = await new Promise((resolve, reject) => {
  let data = "";
  process.stdin.on("readable", () => {
    let chunk;
    while (null !== (chunk = process.stdin.read())) {
      data += chunk;
    }
  });

  process.stdin.on("end", () => {
    resolve(data);
  });

  process.stdin.on('error', err => {
    reject(err)
  })
})

const input = JSON.parse(inputStr)

const output = {
  ...input,
  components: {
    ...input.components,
    schemas: Object.keys(input.components.schemas).reduce((acc, key) => {
      if (!input.components.schemas[key].properties) {
        return {
          ...acc,
          [key]: input.components.schemas[key],
        }
      }
      return {
        ...acc,
        [key]: {
          ...input.components.schemas[key],
          properties: sortByBuckets(Object.keys(input.components.schemas[key].properties), [
            { order: -3, test: key => key === "id" },
            { order: -2, test: key => key.endsWith("Id") },
            { order: -1, test: key => key.startsWith("type") },
            // rest
            { order: 1, test: key => key.endsWith("At") },
            { order: 2, test: key => key === '_embedded' },
          ]).reduce((acc2, key2) => {
            return {
              ...acc2,
              [key2]: input.components.schemas[key].properties[key2],
            }
          }, {}),
        },
      }
    }, {})
  }
}


function sortByBuckets(strs, buckets) {
  const result = {}
  strs.forEach(str => {
    const bucket = buckets.find(b => b.test(str)) || { order: 0, test: () => true }
    result[bucket.order] = [...(result[bucket.order] || []), str]
  })
  return Object.keys(result).map(key => Number.parseInt(key, 10)).sort((a, b) => a - b).reduce((acc, order) => {
    return [
      ...acc,
      ...result[order].sort()
    ]
  }, [])
}

const outputStr = JSON.stringify(output)
process.stdout.write(outputStr)
