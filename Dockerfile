# Install dependencies only when needed
# Production image, copy all the files and run next
FROM node:alpine as proddeps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production 

FROM node:alpine as deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:alpine
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build
RUN rm -rf node_modules
COPY --from=proddeps /app/node_modules ./node_modules


ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

USER nextjs

EXPOSE 3000

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry.
# ENV NEXT_TELEMETRY_DISABLED 1

CMD ["yarn", "start"]