FROM node:16-alpine as deps
WORKDIR /app

COPY --chown=node:node package*.json ./
RUN yarn install --frozen-lockfile
COPY --chown=node:node . .
USER node

FROM node:16-alpine as build

WORKDIR /app
COPY --chown=node:node package*.json ./

# In order to run `npm run build` we need access to the Nest CLI which is a dev dependency. In the previous development stage we ran `npm ci` which installed all dependencies, so we can copy over the node_modules directory from the development image
COPY --chown=node:node --from=deps /app/node_modules ./node_modules

COPY --chown=node:node . .

# Run the build command which creates the production bundle
RUN npm run build

# Set NODE_ENV environment variable
ENV NODE_ENV production

# Running `npm ci` removes the existing node_modules directory and passing in --only=production ensures that only the production dependencies are installed. This ensures that the node_modules directory is as optimized as possible
RUN yarn install --frozen-lockfile --only=production && yarn cache clean --force

USER node

FROM node:16-alpine As production
WORKDIR /app

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/dist ./dist

# Start the server using the production build
CMD [ "node", "dist/main.js" ]
