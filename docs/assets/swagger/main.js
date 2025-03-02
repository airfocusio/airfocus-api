function initSwaggerUI(schema) {
    return SwaggerUIBundle({
        spec: schema,
        dom_id: '#swagger-ui',
        deepLinking: true,
        queryConfigEnabled: true,
        docExpansion: "none",
        tagsSorter,
        operationsSorter,
        syntaxHighlight: {
            activated: true,
            theme: "idea", // agate, arta, monokai, nord, obsidian, tomorrow-night, idea
        },
    });
}

const tagsSorter = bucketSorter([
    { match: v => v === "Global search" },
    { match: v => v === "Items" },
    { match: v => v === "ItemRelations" },
    { match: v => v === "ItemLinks" },
    { match: v => v === "ItemAttachments" },
    { match: v => v === "Workspaces" },
    { match: v => v === "WorkspaceGroups" },
    { match: v => v === "WorkspaceRelations" },
    { match: v => v === "Comments" },
    { match: v => v === "Fields" },
    {},
])

const sortOpByMethodAndPath = bucketSorter([
    { match: v => v.get("method") === "get", sort: sortByPath },
    { match: v => v.get("method") === "post", sort: sortByPath },
    { match: v => v.get("method") === "put", sort: sortByPath },
    { match: v => v.get("method") === "patch", sort: sortByPath },
    { match: v => v.get("method") === "delete", sort: sortByPath },
    { sort: sortByPath },
])

const operationsSorter = bucketSorter([
    { match: v => matchCrudOp(v, "post", "create") },
    { match: v => matchCrudOp(v, "get", "retrieve") },
    { match: v => matchCrudOp(v, "post", "list") },
    { match: v => matchCrudOp(v, "post", "search") },
    { match: v => matchCrudOp(v, "put", "update") },
    { match: v => matchCrudOp(v, "patch", "patch") },
    { match: v => matchCrudOp(v, "delete", "delete") },
    { match: v => matchCrudOp(v, "post", "bulk") },
    { sort: sortOpByMethodAndPath },
    { match: v => v.get("operation").get("deprecated"), sort: sortOpByMethodAndPath },
]);

const schemaPropsSorter = bucketSorter([
    { match: v => v === "id" },
    { match: v => v.endsWith("Id")  },
    { match: v => v.endsWith("Ids")  },
    { match: v => v.startsWith("type")  },
    { match: v => v.endsWith("Type")  },
    { match: v => v === "alias"  },
    { match: v => v === "name"  },
    { match: v => v === "title"  },
    { match: v => v === "description"  },
    { match: v => v === "parents"  },
    { match: v => v === "children"  },
    {},
    { match: v => v.endsWith("At") },
    { match: v => v === "metadata" },
    { match: v => v === "_embedded" },
]);

const fetchSchema = fetch("/openapi.json")
    .then(response => response.json())
    .then(preprocessSchema)

window.onload = () => {
    fetchSchema.then(schema => {
        window.ui = initSwaggerUI(schema);
    })
    document.querySelectorAll(".side-bar .nav-list a.nav-list-link").forEach(function(elem){
        if(elem.href.includes("/endpoints.html")){
            elem.classList.add("active");
            elem.parentNode.classList.add("active");
        }
    });
};

function preprocessSchema(input) {
    for (const schemasName in input.components.schemas) {
        const inputProps = input.components.schemas[schemasName].properties || {}
        const sortedPropNames = Object.keys(inputProps).sort(schemaPropsSorter)
        const sortedProps = {}
        sortedPropNames.forEach(propName => {
            sortedProps[propName] = inputProps[propName]
        })
        input.components.schemas[schemasName].properties = sortedProps
    }

    return input;
}

function sortByPath(a, b) {
    return a.get("path").localeCompare(b.get("path"))
}

function matchCrudOp(v, method, name) {
    const op = v.get("operation")
    const isCRUD = op.get("tags").indexOf("CRUD") >= 0
    return isCRUD && v.get("method") === method && op.get("operationId").startsWith(name)
}

function bucketSorter(buckets) {
    return (a, b) => {
        const defaultBucketId = buckets.findIndex(b => b.match === undefined);
        let aId = defaultBucketId;
        let bId = defaultBucketId;
        let bucketSort = buckets[defaultBucketId]?.sort;
        for (let i = 0; i < buckets.length; i++) {
            if (buckets[i].match === undefined) {
                continue;
            }
            bucketSort = buckets[i].sort || bucketSort;
            if (buckets[i].match(a)) {
                aId = i;
            } else if (buckets[i].match(b)) {
                bId = i;
            }
        }
        bucketSort = bucketSort || ((a, b) => a.localeCompare(b));

        if (aId ===  bId) {
            return bucketSort(a, b);
        } else if (aId < bId) {
            return -1;
        } else {
            return 1;
        }
    }
}
